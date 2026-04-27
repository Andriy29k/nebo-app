import logging
import os
import sys

from flask import Flask, g, jsonify, request
from flask_cors import CORS
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError

from app.database import SessionLocal, engine
from app.models import Base, Item

log = logging.getLogger("catalog.api")


def create_app() -> Flask:
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s %(levelname)s [%(name)s] %(message)s",
        stream=sys.stdout,
    )

    app = Flask(__name__)

    origins = [o.strip() for o in os.getenv("CORS_ORIGINS", "").split(",") if o.strip()]
    if origins:
        CORS(
            app,
            resources={r"/*": {"origins": origins}},
            supports_credentials=True,
            allow_headers=["Content-Type"],
            methods=["GET", "POST", "OPTIONS"],
        )

    try:
        Base.metadata.create_all(bind=engine)
        log.info("schema_checked_created_tables_if_missing")
    except SQLAlchemyError as e:
        log.warning("db_not_ready_at_startup: %s", e)

    @app.before_request
    def open_db():
        if request.method == "OPTIONS":
            return
        g.db = SessionLocal()

    @app.teardown_request
    def close_db(exc):
        db = g.pop("db", None)
        if db is not None:
            db.close()

    def db():
        return g.db

    def item_dict(row: Item) -> dict:
        ts = row.created_at
        return {
            "id": row.id,
            "name": row.name,
            "created_at": ts.isoformat() if ts else None,
        }

    @app.get("/health")
    def health():
        return jsonify(status="ok", service="ops-lab-catalog")

    @app.get("/ready")
    def ready():
        try:
            db().execute(text("SELECT 1")).scalar_one()
            return jsonify(ready=True)
        except SQLAlchemyError as e:
            log.error("ready_check_failed: %s", e)
            return jsonify(detail="database_unavailable"), 503

    @app.get("/items")
    def list_items():
        try:
            rows = db().query(Item).order_by(Item.id).all()
            return jsonify([item_dict(r) for r in rows])
        except SQLAlchemyError as e:
            log.error("list_items_failed: %s", e)
            return jsonify(detail="database_unavailable"), 503

    @app.post("/items")
    def create_item():
        body = request.get_json(silent=True) or {}
        name = (body.get("name") or "").strip()
        if not name or len(name) > 255:
            return jsonify(detail="invalid_name"), 400
        try:
            row = Item(name=name)
            db().add(row)
            db().commit()
            db().refresh(row)
            log.info("item_created id=%s name=%s", row.id, row.name)
            return jsonify(item_dict(row)), 201
        except SQLAlchemyError as e:
            log.error("create_item_failed: %s", e)
            db().rollback()
            return jsonify(detail="database_unavailable"), 503

    return app

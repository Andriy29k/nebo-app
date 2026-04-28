import os

from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "mysql+pymysql://catalog_app:catalog_secret@127.0.0.1:3306/catalog",
)

_connect_kw = {}
if DATABASE_URL.startswith("mysql"):
    _connect_kw["connect_args"] = {
        "charset": "utf8mb4",
        "connect_timeout": 10,
    }

engine = create_engine(DATABASE_URL, pool_pre_ping=True, **_connect_kw)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

"""
Запуск Ops Lab Catalog (Flask).
Сервер слухає мережу і працює, поки не зупините процес (Ctrl+C або systemctl stop).

Gunicorn (Linux): gunicorn -w 2 -b 0.0.0.0:8000 run:app
"""
from app import create_app

app = create_app()

if __name__ == "__main__":
    # threaded=True — кілька одночасних запитів; use_reloader=False — стабільніший процес на ВМ
    app.run(host="0.0.0.0", port=8000, threaded=True, use_reloader=False)

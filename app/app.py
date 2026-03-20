from flask import Flask, jsonify
import os
import time
import logging
from prometheus_client import Counter, Histogram, make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

VERSION = os.getenv("APP_VERSION", "1.0.0")
COMMIT = os.getenv("APP_COMMIT", "unknown")
ENV = os.getenv("APP_ENV", "dev")

REQUEST_COUNT = Counter("app_requests_total", "Total request count")
REQUEST_LATENCY = Histogram("app_request_latency_seconds", "Request latency")
REQUEST_STATUS = Counter("app_request_status_total", "Request status count", ["status"])

app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    "/metrics": make_wsgi_app()
})

@app.route("/")
def home():
    with REQUEST_LATENCY.time():
        REQUEST_COUNT.inc()
        time.sleep(0.1)
        REQUEST_STATUS.labels(status="200").inc()
    app.logger.info("Home endpoint accessed")
    return "DevOps App Running!"

@app.route("/health")
def health():
    return jsonify({"status": "healthy", "timestamp": time.time()}), 200

@app.route("/version")
def version():
    return jsonify({
        "version": VERSION,
        "commit": COMMIT,
        "environment": ENV,
        "timestamp": time.time()
    }), 200

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    host = os.getenv("APP_HOST", "0.0.0.0")  # nosec B104
    app.run(host=host, port=port)

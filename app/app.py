from flask import Flask, jsonify
import os
import time
import logging
from prometheus_client import Counter, Histogram, make_wsgi_app
from werkzeug.middleware.dispatcher import DispatcherMiddleware

app = Flask(__name__)


logging.basicConfig(level=logging.INFO)

VERSION = os.getenv("APP_VERSION", "1.0.0")


REQUEST_COUNT = 0

# Wrap Flask app with Prometheus WSGI app
app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    "/metrics": make_wsgi_app()
})

@app.route("/")
def home():
    import time
    with REQUEST_LATENCY.time():
        REQUEST_COUNT.inc()
        # simulate work
        time.sleep(0.1)
        REQUEST_STATUS.labels(status="200").inc()
        return "DevOps App Running!"
    
@app.route("/")
def home():
    global REQUEST_COUNT
    REQUEST_COUNT += 1

    app.logger.info("Home endpoint accessed")
    return "DevOps App Running!"

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": time.time()
    }), 200

@app.route("/version")
def version():
    return {"version": VERSION}, 200


@app.route("/metrics")
def metrics():
    return f"""
    app_requests_total {REQUEST_COUNT}
    """, 200, {'Content-Type': 'text/plain'}

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    app.run(host="0.0.0.0", port=port)
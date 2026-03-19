from flask import Flask
import os

app = Flask(__name__)

VERSION = os.getenv("APP_VERSION", "1.0.0")

@app.route("/")
def home():
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

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

import logging

logging.basicConfig(level=logging.INFO)

@app.route("/")
def home():
    app.logger.info("Home endpoint accessed")
    return "DevOps App Running!"    
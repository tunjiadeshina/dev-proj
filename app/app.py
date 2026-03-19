from flask import Flask, jsonify  # ✅ jsonify imported
import os
import time                        # ✅ time imported
import logging                     # ✅ moved to top

logging.basicConfig(level=logging.INFO)  # ✅ moved to top

app = Flask(__name__)

VERSION = os.getenv("APP_VERSION", "1.0.0")

@app.route("/")                    # ✅ only one home() route
def home():
    app.logger.info("Home endpoint accessed")
    return "DevOps App Running!"

@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "timestamp": time.time()   # ✅ time now available
    }), 200

@app.route("/version")
def version():
    return {"version": VERSION}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
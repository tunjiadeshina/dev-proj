from flask import Flask
import os

app = Flask(__name__)

VERSION = os.getenv("APP_VERSION", "1.0.0")

@app.route("/health")
def health():
    return {"status": "healthy"}, 200

@app.route("/version")
def version():
    return {"version": VERSION}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
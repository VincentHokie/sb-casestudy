from flask import Flask, jsonify

application = Flask(__name__)

@application.route("/")
def hello():
    return "Flask inside Docker!!"

@application.route("/healthz")
def health():
    resp = jsonify(success=True)
    return resp

if __name__ == "__main__":
    application.run(debug=False, host='0.0.0.0', port=8000)

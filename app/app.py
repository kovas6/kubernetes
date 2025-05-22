from flask import Flask
import psycopg2
import os

app = Flask(__name__)

@app.route("/")
def hello():
    try:
        conn = psycopg2.connect(
            dbname = os.getenv("POSTGRES_DB"),
            user=os.getenv("POSTGRES_USER"),
            password=os.getenv("POSTGRES_PASSWORD"),
            host=os.getenv("POSTGRES_HOST"),
            port="5432"
        )
        cur = conn.cursor()
        cur.execute("SELECT message FROM greetings LIMIT 1;")
        message = cur.fetchone()
        cur.close()
        conn.close()
        return f"<h1>{message[0]}</h1>" if message else "No message found"
    except Exception as e:
        return f"<h1>Error: {e}</h1>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

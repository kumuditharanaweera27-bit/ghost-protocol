"""
Ghost Protocol - ST-03: The Open Door
Deliberately vulnerable Nexora Technologies employee portal.
"""

import os
import sqlite3
from flask import Flask, render_template, request, redirect, url_for, session, send_from_directory

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "nexora-ctf-dev-key")

DB_PATH = os.path.join(os.path.dirname(__file__), "nexora.db")
FLAG = os.environ.get("ST03_FLAG", "NEXORA{sql1_th3_0p3n_d00r}")


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    conn = get_db()
    conn.executescript(
        """
        DROP TABLE IF EXISTS users;
        CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'employee'
        );
        """
    )
    conn.executemany(
        "INSERT INTO users (username, password, role) VALUES (?, ?, ?)",
        [
            ("jmorales", "autumn2025", "employee"),
            ("rchen", "nexora!23", "employee"),
            ("sokonkwo", "N3x0ra_Adm1n_2026", "admin"),
        ],
    )
    conn.commit()
    conn.close()


@app.route("/")
def index():
    return render_template("portal.html")


@app.route("/directory")
def directory():
    staff = [
        {"name": "J. Morales", "username": "jmorales", "dept": "Client Services"},
        {"name": "R. Chen", "username": "rchen", "dept": "Operations"},
        {"name": "A. Morgan", "username": "amorgan", "dept": "Security — on leave"},
        {"name": "T. Weerasinghe", "username": "tweerasinghe", "dept": "Finance"},
        {"name": "D. Oyelaran", "username": "doyelaran", "dept": "Client Services"},
        {"name": "S. Okonkwo", "username": "sokonkwo", "dept": "IT"},
    ]
    return render_template("directory.html", staff=staff)


@app.route("/announcements")
def announcements():
    notices = [
        {
            "title": "Scheduled maintenance — file server",
            "body": "The internal file server will be offline for maintenance this weekend. "
                    "Contact IT if you need urgent access before then.",
        },
        {
            "title": "Reminder: badge access policy",
            "body": "All staff must badge in at the east entrance after 7pm. "
                    "Tailgating will be reported to Security.",
        },
        {
            "title": "Login system update pending",
            "body": "IT is aware the employee portal's authentication module is overdue "
                    "for a rebuild. A ticket has been open for several months; please be "
                    "patient while this gets prioritised.",
        },
    ]
    return render_template("announcements.html", notices=notices)


@app.route("/login", methods=["GET", "POST"])
def login():
    error = None
    if request.method == "POST":
        username = request.form.get("username", "")
        password = request.form.get("password", "")

        query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
        conn = get_db()
        try:
            cur = conn.execute(query)
            user = cur.fetchone()
        except sqlite3.Error:
            user = None
        conn.close()

        if user:
            session["user_id"] = user["id"]
            session["username"] = user["username"]
            session["role"] = user["role"]
            return redirect(url_for("dashboard"))
        error = "Invalid username or password."

    return render_template("login.html", error=error)


@app.route("/dashboard")
def dashboard():
    if "user_id" not in session:
        return redirect(url_for("login"))
    is_admin = session.get("role") == "admin"
    return render_template("dashboard.html", username=session["username"], is_admin=is_admin)


@app.route("/restricted")
def restricted():
    if session.get("role") != "admin":
        return render_template("denied.html"), 403
    return render_template("restricted.html", flag=FLAG)


@app.route("/restricted/download/<path:filename>")
def download_archive(filename):
    if session.get("role") != "admin":
        return render_template("denied.html"), 403
    return send_from_directory(os.path.join(os.path.dirname(__file__), "artifacts"), filename, as_attachment=True)


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("index"))


if __name__ == "__main__":
    if not os.path.exists(DB_PATH):
        init_db()
    app.run(host="0.0.0.0", port=5000, debug=False)

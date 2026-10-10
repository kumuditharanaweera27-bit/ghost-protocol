FROM python:3.11-slim
RUN useradd -m -u 1000 ctfuser
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
COPY templates ./templates
COPY static ./static
COPY artifacts ./artifacts
ENV FLASK_APP=app.py
RUN chown -R ctfuser:ctfuser /app
USER ctfuser

EXPOSE 5000
CMD ["python", "-c", "from app import init_db, app; init_db(); app.run(host='0.0.0.0', port=5000)"]

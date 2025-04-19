# ---
# Base container
# ---
FROM python:3.12-alpine as base

RUN adduser --disabled-password --gecos '' flaskuser

WORKDIR /app

COPY requirements.txt .
COPY app.py .
COPY db/config.py db/config.py

RUN chown -R flaskuser:flaskuser /app
RUN pip install --no-cache-dir -r requirements.txt

USER flaskuser

# ---
# Test container
# ---
FROM base as tester

COPY tests/ tests/
COPY tests/requirements.txt tests/
RUN pip install --no-cache-dir -r tests/requirements.txt
RUN python -m pytest -s tests/

# ---
# Production container
# ---
FROM base

ENV PYTHONUNBUFFERED 1
EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
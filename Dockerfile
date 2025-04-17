FROM python:3.12-alpine

RUN adduser --disabled-password --gecos '' flaskuser

WORKDIR /app

COPY app/requirements.txt .
COPY app/app.py .

RUN chown -R flaskuser:flaskuser /app

RUN pip install --no-cache-dir -r requirements.txt

USER flaskuser
ENV PYTHONUNBUFFERED 1
EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
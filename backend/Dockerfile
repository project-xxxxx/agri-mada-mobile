FROM python:3.12-slim

WORKDIR /app

# Prevent Python from writing pyc files and buffering stdout/stderr
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install system dependencies if needed (e.g., for PostgreSQL)
RUN apt-get update \
    && apt-get install -y gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Le serveur ne tourne pas en root.
RUN useradd --create-home --uid 10001 agrimada && chown -R agrimada /app
USER agrimada

EXPOSE 8000

# Migrations puis serveur, sans --reload (réservé au développement local).
# SECRET_KEY doit être fourni par l'environnement : le serveur refuse de démarrer sans.
CMD ["sh", "-c", "alembic upgrade head && exec uvicorn app.main:app --host 0.0.0.0 --port 8000"]

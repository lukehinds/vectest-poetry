# -----------------------------
# Builder Stage
# -----------------------------
FROM python:3.12-slim AS builder

# Install system dependencies for Python dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Set working directory
WORKDIR /app

# Copy pyproject.toml and poetry.lock
COPY pyproject.toml poetry.lock /app/

# Install dependencies
RUN poetry config virtualenvs.create false && poetry install --no-interaction

# -----------------------------
# Runtime Stage
# -----------------------------
FROM python:3.12-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libsqlite3-0 \
    file \
    && rm -rf /var/lib/apt/lists/*

# Set working directory for app
WORKDIR /app

# Copy installed dependencies from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages

# Copy application code
COPY vector_test.py .

# Validate sqlite_vec integration
RUN file /usr/local/lib/python3.12/site-packages/sqlite_vec/vec0.so
RUN python -c "import sqlite3; print(sqlite3.sqlite_version)"
RUN python -c "import sqlite3; conn = sqlite3.connect(':memory:'); conn.enable_load_extension(True); conn.load_extension('/usr/local/lib/python3.12/site-packages/sqlite_vec/vec0'); print('sqlite_vec loaded successfully')"

# Run the application
CMD ["python", "vector_test.py"]

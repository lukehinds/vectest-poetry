# -----------------------------
# Builder Stage
# -----------------------------
FROM python:3.12-slim AS builder

# Install system dependencies for Python dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    file \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# -----------------------------
# Runtime Stage
# -----------------------------
FROM python:3.12-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libsqlite3-0 \
    build-essential \
    curl \
    git \
    file \
    gettext-base \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install sqlite-vec from Source
WORKDIR /tmp

# Download and Build sqlite-vec
RUN curl -L $(curl -s https://api.github.com/repos/asg017/sqlite-vec/releases/latest | grep "tarball_url" | cut -d '"' -f 4) -o sqlite-vec.tar.gz && \
    tar xvfz sqlite-vec.tar.gz && \
    cd asg017* && \
    sh scripts/vendor.sh && \
    echo "#include <sys/types.h>" | cat - sqlite-vec.c > temp && mv temp sqlite-vec.c && \
    make loadable && \
    mkdir -p /usr/local/lib/python3.12/site-packages/sqlite_vec && \
    cp dist/vec0.so /usr/local/lib/python3.12/site-packages/sqlite_vec/vec0.so && \
    zip -j /usr/local/lib/python3.12/site-packages/sqlite_vec/sqlite-vec.zip dist/vec0.so && \
    cd /tmp && rm -rf sqlite-vec.tar.gz asg017*

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

# -------- Stage 1: Builder (installs dependencies) --------
FROM python:3.9-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Minimal system deps (NO build-essential unless really needed)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install pip deps into a clean directory
RUN pip install --upgrade pip && \
    pip install --no-cache-dir --prefix=/install \
    torch==2.1.0+cpu \
    -f https://download.pytorch.org/whl/torch_stable.html && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt


# -------- Stage 2: Runtime (SMALL image) --------
FROM python:3.9-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Copy only installed packages from builder
COPY --from=builder /install /usr/local

# Copy app code
COPY . .

EXPOSE 8000

CMD ["uvicorn", "api.main:app", "--host", "0.0.0.0", "--port", "8000"]

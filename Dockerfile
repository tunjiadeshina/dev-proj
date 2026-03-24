# Use specific version tag not latest
FROM python:3.11-slim

# Run as non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir --upgrade "jaraco.context>=6.1.0" "wheel>=0.46.2"

COPY app/ .

# Change ownership
RUN chown -R appuser:appuser /app

# Switch to non-root
USER appuser

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

CMD ["python", "app.py"]

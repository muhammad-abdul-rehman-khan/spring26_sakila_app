# 1. Use a slim base image to reduce size and attack surface
FROM python:3.9-slim

# 2. Add Metadata Labels as required (Requirement 27)
LABEL maintainer="muhammad-abdul-rehman-khan" \
      version="1.0" \
      description="Optimized Sakila Flask Application for DevOps Assignment"

# 3. Environment variables to optimize Python performance
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    MYSQL_HOST=db-server \
    MYSQL_USER=app_user \
    MYSQL_DB=sakila

# Set the working directory
WORKDIR /app

# 4. Security: Create a non-root system user and group
RUN addgroup --system appgroup && adduser --system --group appuser

# 5. Optimization: Copy only requirements first to leverage Docker layer caching
COPY requirements.txt .

# Install dependencies without saving the cache (reduces image size)
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copy the rest of the application code
COPY . .

# 7. Security: Give the non-root user ownership of the app files
RUN chown -R appuser:appgroup /app

# 8. Security: Switch to the non-root user
USER appuser

# 9. Expose only the necessary application port
EXPOSE 5000

# 10. Healthcheck: Monitor application status (Requirement 27)
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:5000/health || exit 1

# Start the application
CMD ["python", "app.py"]
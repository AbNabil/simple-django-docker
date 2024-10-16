# Use the official Python image as a base image
FROM python:3.12-slim

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set the working directory in the container
WORKDIR /app

# Install system dependencies in one layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the requirements file first to leverage Docker caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir gunicorn

# Create a non-root user named 'django' and switch to it
RUN useradd -m django

# Change ownership of the application directory to the new user
RUN chown -R django:django /app

# Switch to the non-root user
USER django

# Copy the entire project into the working directory
COPY --chown=django:django . .

# Ensure entrypoint.sh is executable
RUN chmod +x /app/entrypoint.sh

# Expose the port the app runs on
EXPOSE 8000

# Set the entrypoint for the container to start Gunicorn
ENTRYPOINT ["/app/entrypoint.sh"]

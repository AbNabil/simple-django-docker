# Use the official Python image as a base image
FROM python:3.12-slim as base

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set the working directory in the container
WORKDIR /app

# Install system dependencies, create a non-root user, and set permissions in one layer
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m django_user \
    && chown -R django_user:django_user /app

# Switch to the new user
USER django_user

# Copy the entire project into the working directory
COPY --chown=django_user:django_user . .

# Ensure entrypoint.sh is executable
RUN chmod +x /app/entrypoint.sh

# Install Python dependencies including Gunicorn
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn

# Use Gunicorn to run the application
FROM python:3.12-slim as production

# Set the working directory in the container
WORKDIR /app

# Copy the installed Python packages and the app from the base image
COPY --from=base /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=base /app /app

# Create a non-root user and set permissions
RUN useradd -m django_user && chown -R django_user:django_user /app

# Switch to the new user
USER django_user

# Expose the port the app runs on
EXPOSE 8000

# Set the entrypoint for the container
ENTRYPOINT ["/app/entrypoint.sh"]

# Use the official Python image as a base image
FROM python:3.12-slim as base

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory in the container
WORKDIR /app

# Install system dependencies for building packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user with a descriptive username
RUN useradd -m django_user

# Change ownership of the /app directory to the new user
RUN chown -R django_user:django_user /app

# Switch to the new user
USER django_user

# Copy the requirements file
COPY --chown=django_user:django_user requirements.txt .

# Install Python dependencies including Gunicorn
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn

# Copy the entire project into the working directory
COPY --chown=django_user:django_user . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Use Gunicorn to run the application
FROM python:3.12-slim as production

# Set the working directory in the container
WORKDIR /app

# Copy the installed Python packages from the base image
COPY --from=base /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=base /app /app

# Create a non-root user with a descriptive username
RUN useradd -m django_user

# Change ownership of the /app directory to the new user
RUN chown -R django_user:django_user /app

# Switch to the new user
USER django_user

# Expose the port the app runs on
EXPOSE 8000

# Run the application with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "simple.wsgi:application"]

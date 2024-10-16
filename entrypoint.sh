#!/bin/sh

# Collect static files
python manage.py collectstatic --noinput

# Start the application with Gunicorn
exec gunicorn --bind 0.0.0.0:8000 simple.wsgi:application

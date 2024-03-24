#!/bin/bash

python manage.py migrate

python manage.py createsuperuser --noinput --username=$DJANGO_SUPERUSER_USERNAME --email=$DJANGO_SUPERUSER_EMAIL

if [ $? -ne 0 ]; then
    echo "Superuser já existe. Ignorando a criação."
fi

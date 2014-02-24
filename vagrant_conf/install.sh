#!/bin/bash

sudo apt-get update -y
sudo apt-get install python-dev python3 python-virtualenv -y

cd /vagrant/
source venv/bin/activate

pip install -r requirements.txt

gunicorn django_vagrant.wsgi:application --bind 0.0.0.0:8042

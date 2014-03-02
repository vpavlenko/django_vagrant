#!/bin/bash
 
# Activate the virtual environment
source /vagrant/venv/bin/activate
export PYTHONPATH=/vagrant:$PYTHONPATH
 
cat /vagrant/django_vagrant_core_scripts/db_admin_credentials.txt | python3 /vagrant/manage.py syncdb
# TODO: add migrations here
python3 /vagrant/manage.py collectstatic --noinput

python3 /vagrant/manage.py runserver --noreload 0.0.0.0:8042

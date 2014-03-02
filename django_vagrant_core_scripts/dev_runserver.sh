#!/bin/bash
 
MANAGE_PY=/vagrant/source/manage.py

# Activate the virtual environment
source /vagrant/venv/bin/activate
export PYTHONPATH=/vagrant/source:$PYTHONPATH

if [ ! `stat $MANAGE_PY` ] ; then
    sleep 2;
fi 
cat /vagrant/django_vagrant_core_scripts/db_admin_credentials.txt | python $MANAGE_PY syncdb
# TODO: add migrations here
python $MANAGE_PY collectstatic --noinput

python $MANAGE_PY runserver --noreload 0.0.0.0:8042

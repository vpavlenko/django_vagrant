#!/bin/bash
 
MANAGE_PY=/vagrant/source/manage.py

# Activate the virtual environment
source /vagrant/venv/bin/activate
export PYTHONPATH=/vagrant/source:$PYTHONPATH

if [ ! `stat $MANAGE_PY` ] ; then
    sleep 2;
fi 
cat /vagrant/django_vagrant_core_scripts/db_admin_credentials.txt | python $MANAGE_PY --settings=django_vagrant.settings.dev syncdb
# TODO: add migrations here
python $MANAGE_PY collectstatic --settings=django_vagrant.settings.dev --noinput

python $MANAGE_PY runserver --noreload --settings=django_vagrant.settings.dev 0.0.0.0:8042

#!/bin/bash

set -x
 
SCRIPT_DIR="/home/vagrant/scripts"

NAME="django_vagrant"
PROJECT_ROOT_DIR="/home/vagrant/prod/django_vagrant_package"
SOCKET=127.0.0.1:9000
# SOCKFILE=/var/run/gunicorn.sock  # be the first who setups it properly :)
USER=vagrant
GROUP=vagrant
NUM_WORKERS=3
DJANGO_SETTINGS_MODULE=$NAME.settings.prod
DJANGO_WSGI_MODULE=$NAME.wsgi
 
echo "Starting $NAME as `whoami`"
 
# Activate the virtual environment
cd $PROJECT_ROOT_DIR
source $PROJECT_ROOT_DIR/venv/bin/activate
cd source/
export PYTHONPATH=`pwd`:$PYTHONPATH
# TODO: does it take any effect
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE

# TODO: replace with connection to MySQL
cat /vagrant/django_vagrant_core_scripts/db_admin_credentials.txt | python3 manage.py syncdb --settings=django_vagrant.settings.prod

# # This should be done while we build the package
# python3 manage.py collectstatic --noinput

# Load env variables for settings file
source $SCRIPT_DIR/prod_envs.sh

# We should use local gunicorn, it's the only easy way to pass virtualenv to it
gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user=$USER --group=$GROUP \
  --log-level=debug \
  --bind 0.0.0.0:9000
#  --bind=unix:$SOCKFILE

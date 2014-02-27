#!/bin/bash
 
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

NAME="django_vagrant"
PROJECT_ROOT_DIR="/home/vagrant/django_vagrant_prod"
SOCKET=127.0.0.1:9000
# SOCKFILE=/var/run/gunicorn.sock  # be the first who setups it properly :)
USER=vagrant
GROUP=vagrant
NUM_WORKERS=3
DJANGO_SETTINGS_MODULE=$NAME.settings
DJANGO_WSGI_MODULE=$NAME.wsgi
 
echo "Starting $NAME as `whoami`"
 
# Activate the virtual environment
cd $PROJECT_ROOT_DIR
source $PROJECT_ROOT_DIR/venv/bin/activate
export DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE
export PYTHONPATH=$PROJECT_ROOT_DIR:$PYTHONPATH
 
cat vagrant_conf/db_admin_credentials.txt | python3 manage.py syncdb
python3 manage.py collectstatic --noinput

gunicorn ${DJANGO_WSGI_MODULE}:application \
  --name $NAME \
  --workers $NUM_WORKERS \
  --user=$USER --group=$GROUP \
  --log-level=debug \
  --bind 0.0.0.0:9000
#  --bind=unix:$SOCKFILE

#!/bin/bash

# sudo apt-get update -y
sudo apt-get install python-dev python3 python-virtualenv nginx -y

cd /vagrant/

cp vagrant_conf/django_vagrant_nginx.conf /etc/nginx/sites-available/
pushd /etc/nginx/sites-enabled
ln -s /etc/nginx/sites-available/django_vagrant_nginx.conf
popd
mkdir logs
service nginx restart

# virtualenv -p python3 venv
source venv/bin/activate

# pip install -r requirements.txt

# gunicorn django_vagrant.wsgi:application --bind 0.0.0.0:8042
killall -9 gunicorn
. /vagrant/vagrant_conf/gunicorn_run.sh
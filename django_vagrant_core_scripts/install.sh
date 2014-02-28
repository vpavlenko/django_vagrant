#!/bin/bash

export VAGRANT_CONF_DIR=django_vagrant_core_scripts

sudo apt-get update -y
sudo apt-get install git vim python3-dev python3 python-virtualenv nginx supervisor -y

chgrp vagrant /vagrant/
cd /vagrant/

cp $VAGRANT_CONF_DIR/django_vagrant_nginx.conf /etc/nginx/sites-available/
pushd /etc/nginx/sites-enabled
ln -s /etc/nginx/sites-available/django_vagrant_nginx.conf
popd
service nginx restart

virtualenv -p python3 venv
source venv/bin/activate

pip install -v --log /tmp/venv_install.log -r requirements.txt

mkdir -p /home/vagrant/scripts/
cp $VAGRANT_CONF_DIR/dev_runserver.sh /home/vagrant/scripts/
cp $VAGRANT_CONF_DIR/prod_gunicorn.sh /home/vagrant/scripts/

cp $VAGRANT_CONF_DIR/django_vagrant_dev_supervisor.conf /etc/supervisor/conf.d/
cp $VAGRANT_CONF_DIR/django_vagrant_prod_supervisor.conf /etc/supervisor/conf.d/
service supervisor stop
service supervisor start

su -p - vagrantman 
$VAGRANT_CONF_DIR/launch_prod_debug_false.sh

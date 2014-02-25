#!/bin/bash

sudo apt-get update -y
sudo apt-get install vim python-dev python3 python-virtualenv nginx supervisor -y

cd /vagrant/

cp vagrant_conf/django_vagrant_nginx.conf /etc/nginx/sites-available/
pushd /etc/nginx/sites-enabled
ln -s /etc/nginx/sites-available/django_vagrant_nginx.conf
popd
service nginx restart

cp vagrant_conf/django_vagrant_supervisor.conf /etc/supervisor/conf.d/
supervisorctl reread
supervisorctl update

virtualenv -p python3 venv
source venv/bin/activate

pip install -v --log venv/install.log -r requirements.txt

supervisorctl restart django_vagrant

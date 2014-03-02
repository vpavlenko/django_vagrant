#!/bin/bash

set -x

if [ `whoami` != 'root' ] ; then
    echo "This script should be run as root"
    exit 1
fi

SCRIPT_DIR=/vagrant/django_vagrant_core_scripts
export VAGRANT_CONF_DIR=$SCRIPT_DIR

sudo apt-get update -y
sudo apt-get install -y git vim python-dev python3-dev python python3 \
    python-virtualenv python-setuptools python3-setuptools nginx supervisor
# We need version 1.1 or higher. easy_install3 gives at least 1.5.4
sudo easy_install pip
sudo easy_install3 pip

# /vagrant is mount point for the repository root
chgrp vagrant /vagrant/

# Configure nginx
cp $VAGRANT_CONF_DIR/django_vagrant_nginx.conf /etc/nginx/sites-available/
pushd /etc/nginx/sites-enabled
ln -s /etc/nginx/sites-available/django_vagrant_nginx.conf
popd
service nginx restart

# Configure virtualenv
sudo -u vagrant -H /bin/bash -c "$VAGRANT_CONF_DIR/configure_virtualenv.sh /vagrant/venv dev"

# Configure supervisor, runserver and gunicorn
mkdir -p /home/vagrant/scripts/
cp $VAGRANT_CONF_DIR/dev_runserver.sh /home/vagrant/scripts/
cp $VAGRANT_CONF_DIR/prod_gunicorn.sh /home/vagrant/scripts/
cp $VAGRANT_CONF_DIR/django_vagrant_dev_supervisor.conf /etc/supervisor/conf.d/
cp $VAGRANT_CONF_DIR/django_vagrant_prod_supervisor.conf /etc/supervisor/conf.d/
service supervisor stop
service supervisor start

# su -c $VAGRANT_CONF_DIR/launch_prod_debug_false.sh -s /bin/bash vagrant
sudo -u vagrant -H /bin/bash -c "$VAGRANT_CONF_DIR/build_and_launch_prod_debug_false.sh"

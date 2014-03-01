#!/bin/bash

set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export VAGRANT_CONF_DIR=$SCRIPT_DIR

sudo apt-get update -y
sudo apt-get install -y git vim python3-dev python3 python-virtualenv \
    python-setuptools python3-setuptools nginx supervisor
# We need version 1.1 or higher. easy_install3 gives at least 1.5.4
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
su vagrant <<'EOF'
if [ ! -e /vagrant/venv ] ; then
    virtualenv -p python3 /vagrant/venv
fi
source /vagrant/venv/bin/activate
pip install -v --log /tmp/dev_venv_install.log -r /vagrant/requirements.txt
EOF

# Configure supervisor, runserver and gunicorn
mkdir -p /home/vagrant/scripts/
cp $VAGRANT_CONF_DIR/dev_runserver.sh /home/vagrant/scripts/
cp $VAGRANT_CONF_DIR/prod_gunicorn.sh /home/vagrant/scripts/
cp $VAGRANT_CONF_DIR/django_vagrant_dev_supervisor.conf /etc/supervisor/conf.d/
cp $VAGRANT_CONF_DIR/django_vagrant_prod_supervisor.conf /etc/supervisor/conf.d/
service supervisor stop
service supervisor start

# su -c $VAGRANT_CONF_DIR/launch_prod_debug_false.sh -s /bin/bash vagrant
sudo -u vagrant -H /bin/bash -c $VAGRANT_CONF_DIR/launch_prod_debug_false.sh

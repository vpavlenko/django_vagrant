#!/bin/bash

set -x

PYTHON=`cat /vagrant/python.version`
VENV_PATH=$1
PREFIX=$2

if [ ! -e $VENV_PATH ] ; then
    virtualenv -p $PYTHON $VENV_PATH
fi
source $VENV_PATH/bin/activate
pip install -v --log /tmp/$2_venv_install.log -r /vagrant/requirements.txt

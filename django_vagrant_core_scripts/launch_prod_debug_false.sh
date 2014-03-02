#!/bin/bash

set -x

if [ `whoami` != 'vagrant' ] ; then
    echo "build_prod.sh should be called from vagrant user"
    echo "current user: `whoami`"
    exit 1
fi

if [[ -z $1 ]] ; then
    echo "Usage: launch_prod_debug_false.sh /vagrant/packages/PACKAGE.tar.gz"
    exit 1
fi

SCRIPT_DIR=/vagrant/django_vagrant_core_scripts
PROD_DIR=/home/vagrant/prod
PACKAGE=$1

mkdir -p $PROD_DIR
cd $PROD_DIR
cp $1 .
rm -rf django_vagrant_package
tar xvf `basename $1`

sudo service supervisor stop
sudo service supervisor start

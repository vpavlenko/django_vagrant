#!/bin/bash

set -x

SCRIPT_DIR=/vagrant/django_vagrant_core_scripts
PACKAGES_DIR=/vagrant/packages
PROD_DIR=/home/vagrant/prod

# Build a package
$SCRIPT_DIR/build_prod.sh || exit 1

# Unpack it
mkdir -p $PROD_DIR
cd $PROD_DIR
cp $PACKAGES_DIR/django_vagrant_package.tar.gz .
rm -rf django_vagrant_package
tar xvf django_vagrant_package.tar.gz

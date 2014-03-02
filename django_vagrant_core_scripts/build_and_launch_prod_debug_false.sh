#!/bin/bash

set -x

SCRIPT_DIR=/vagrant/django_vagrant_core_scripts
PACKAGES_DIR=/vagrant/packages
PROD_DIR=/home/vagrant/prod

# Build a package
$SCRIPT_DIR/build_prod.sh || exit 1

$SCRIPT_DIR/launch_prod_debug_false.sh $PACKAGES_DIR/django_vagrant_package.tar.gz

#!/bin/bash

set -x

SCRIPT_DIR=/vagrant/django_vagrant_core_scripts
PROD_DIR=/home/vagrant/prod

$SCRIPT_DIR/build_prod.sh || exit 1

$SCRIPT_DIR/launch_prod.sh

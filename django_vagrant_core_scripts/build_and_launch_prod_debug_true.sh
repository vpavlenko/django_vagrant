#!/bin/bash

set -x

SCRIPT_DIR=/vagrant/django_vagrant_core_scripts

cp $SCRIPT_DIR/debug_true_envs.sh /home/vagrant/scripts/prod_envs.sh

$SCRIPT_DIR/build_and_launch_prod.sh

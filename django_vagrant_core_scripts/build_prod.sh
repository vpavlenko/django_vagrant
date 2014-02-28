#!/bin/bash

set -x

VAGRANT_CONF_DIR=django_vagrant_core_scripts
PACKAGE_SANDBOX=/home/vagrant/package_sandbox
PACKAGE_DIR=$PACKAGE_SANDBOX/django_vagrant_package
DEST_DIR=/vagrant/packages

pushd /vagrant
GIT_BRANCH=`git branch | grep "*" | sed "s/^* //"`
GIT_COMMIT=`git log | head -n 1 | sed "s/^commit //" | cut -c 1-7`
if `git status | grep "nothing to commit"` ; then
    GIT_WITH_CHANGES="exact"
else
    GIT_WITH_CHANGES="changed"
fi
PROD_PACKAGE_SUFFIX=$GIT_BRANCH_$GIT_COMMIT_$GIT_WITH_CHANGES
popd

# Check if /vagrant/venv/ corresponds to requirements.txt
source /vagrant/venv/bin/activate
pip freeze > /tmp/requirements.txt
if ! `diff /vagrant/requirements.txt /tmp/requirements.txt` ; then
    echo "/vagrant/requirements.txt differs from pip freeze, I can't get over it"
    echo ""
    diff /vagrant/requirements.txt /tmp/requirements.txt
    exit 1
fi

rm -rf $PACKAGE_DIR
mkdir -p $PACKAGE_DIR

rsync -av --exclude venv --exclude requirements.txt \
    --exclude .git --exclude .gitignore \
    --exclude Vagrantfile --exclude $VAGRANT_CONF_DIR --exclude .vagrant \
    --exclude collected_static /vagrant/* $PACKAGE_DIR/source/

rsync -av /vagrant/collected_static $PACKAGE_DIR

# --relocatable doesn't change bin/activate script, so it will be broken
# in destination venv
virtualenv --relocatable /vagrant/venv
rsync -av /vagrant/venv $PACKAGE_DIR

mkdir $DEST_DIR
tar czvf $DEST_DIR/django_vagrant_package.tar.gz $PACKAGE_DIR
echo $PROD_PACKAGE_SUFFIX

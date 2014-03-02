#!/bin/bash

set -x

if [ `whoami` != 'vagrant' ] ; then
    echo "build_prod.sh should be called from vagrant user"
    echo "current user: `whoami`"
    exit 1
fi

VAGRANT_CONF_DIR=/vagrant/django_vagrant_core_scripts
PACKAGE_SANDBOX=/home/vagrant/package_sandbox
PACKAGE_SUFFIX=django_vagrant_package
PACKAGE_DIR=$PACKAGE_SANDBOX/$PACKAGE_SUFFIX
PACKAGE_ARCHIVE=django_vagrant_package.tar.gz
PACKAGES_DIR=/vagrant/packages

# Collect information about current branch and commit
# In the future we will be name our package according to this suffix
pushd /vagrant
GIT_BRANCH=`git branch | grep "*" | sed "s/^* //"`_
GIT_COMMIT=`git log | head -n 1 | sed "s/^commit //" | cut -c 1-7`
if `git status | grep "nothing to commit"` ; then
    GIT_WITH_CHANGES="_exact_commit"
else
    GIT_WITH_CHANGES="_changed_from_commit"
fi
PROD_PACKAGE_SUFFIX=$GIT_BRANCH$GIT_COMMIT$GIT_WITH_CHANGES.tar.gz
popd

# Check if /vagrant/venv/ corresponds to requirements.txt
# source /vagrant/venv/bin/activate
/vagrant/venv/bin/pip freeze > /tmp/requirements.txt
if ! `diff /vagrant/requirements.txt /tmp/requirements.txt` ; then
    echo "/vagrant/requirements.txt differs from /vagrant/venv/bin/pip freeze, I can't get over it"
    echo ""
    diff /vagrant/requirements.txt /tmp/requirements.txt
    exit 1
fi

/vagrant/venv/bin/python3 /vagrant/manage.py collectstatic --noinput

rm -rf $PACKAGE_DIR
mkdir -p $PACKAGE_DIR

rsync -av --exclude venv \
    --exclude .git --exclude .gitignore \
    --exclude Vagrantfile --exclude $VAGRANT_CONF_DIR --exclude .vagrant \
    --exclude django_vagrant_core_scripts --exclude packages \
    --exclude collected_static /vagrant/* $PACKAGE_DIR/source/

rsync -av /vagrant/collected_static $PACKAGE_DIR

# virtualenv --relocatable /vagrant/venv
# rsync -av /vagrant/venv $PACKAGE_DIR
#
# --relocatable doesn't change bin/activate script, so it will be broken
# in destination venv. therefore the only viable way to have live venv
# is:
# 1. recreate it in the target directory
# 2. never change the path to it
#
# it sucks tremendously, but I don't know how to call local gunicorn without
# calling 'source venv/bin/activate', and calling local gunicorn is crucial
# for passing the right virtualenv to it

virtualenv -p python3 $PACKAGE_DIR/venv
source $PACKAGE_DIR/venv/bin/activate
which pip
pip install -q --log /tmp/prod_venv_install.log -r /vagrant/requirements.txt || exit 1
if [ ! $? ] ; then
    echo "pip install failed, see /tmp/prod_venv_install.log for the details"
    echo
    exit 1
fi

pushd $PACKAGE_SANDBOX
tar czvf $PACKAGE_ARCHIVE $PACKAGE_SUFFIX
popd

mkdir $PACKAGES_DIR
mv $PACKAGE_SANDBOX/$PACKAGE_ARCHIVE $PACKAGES_DIR

cp $PACKAGES_DIR/$PACKAGE_ARCHIVE $PACKAGES_DIR/$PROD_PACKAGE_SUFFIX

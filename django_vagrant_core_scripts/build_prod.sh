#!/bin/bash

set -x

if [ `whoami` != 'vagrant' ] ; then
    echo "build_prod.sh should be called from vagrant user"
    echo "current user: `whoami`"
    exit 1
fi

VAGRANT_CONF_DIR=/vagrant/django_vagrant_core_scripts
PACKAGES_DIR=/vagrant/packages
PACKAGE_SUPERDIR=/home/vagrant/prod
PROD_SYMLINK=$PACKAGE_SUPERDIR/django_vagrant_package

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
PROD_PACKAGE_SUFFIX=$GIT_BRANCH$GIT_COMMIT$GIT_WITH_CHANGES
PROD_PACKAGE_ARCHIVE=$PACKAGES_DIR/$PROD_PACKAGE_SUFFIX.tar.gz
PACKAGE_DIR=$PACKAGE_SUPERDIR/$PROD_PACKAGE_SUFFIX
popd

# Check if /vagrant/venv/ corresponds to requirements.txt
# source /vagrant/venv/bin/activate
/vagrant/venv/bin/pip freeze > /tmp/requirements.txt
if ! `diff /vagrant/requirements.txt /tmp/requirements.txt` ; then
    echo "/vagrant/requirements.txt differs from /vagrant/venv/bin/pip freeze, I can't get over it"
    diff /vagrant/requirements.txt /tmp/requirements.txt
    exit 1
fi

/vagrant/venv/bin/python /vagrant/source/manage.py collectstatic --settings=django_vagrant.settings.dev --noinput

rm -rf $PACKAGE_DIR
mkdir -p $PACKAGE_DIR

rsync -av /vagrant/source $PACKAGE_DIR

rsync -av /vagrant/collected_static $PACKAGE_DIR
mv $PACKAGE_DIR/collected_static $PACKAGE_DIR/static

# --relocatable doesn't change bin/activate script, so it will be broken
# in destination venv. therefore the only viable way to have live venv
# is:
# 1. recreate it in the target directory
# 2. never change the path to it
sudo -u vagrant -H /bin/bash -c "$VAGRANT_CONF_DIR/configure_virtualenv.sh $PACKAGE_DIR/venv prod"
if [ ! $? ] ; then
    echo "pip install failed, see /tmp/prod_venv_install.log for the details"
    echo
    exit 1
fi

cd /
mkdir $PACKAGES_DIR
rm $PROD_PACKAGE_ARCHIVE
tar czvf $PROD_PACKAGE_ARCHIVE $PACKAGE_DIR

rm -rf $PROD_SYMLINK
ln -s $PACKAGE_DIR $PROD_SYMLINK

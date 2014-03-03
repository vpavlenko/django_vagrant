#!/bin/bash

set -x

if [ `whoami` != 'vagrant' ] ; then
    echo "build_prod.sh should be called from vagrant user"
    echo "current user: `whoami`"
    exit 1
fi

sudo service supervisor stop
sudo service supervisor start

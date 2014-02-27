Scaffold for Django application
-------------------------------

The major goal of this repo is to scaffold and automate three things:
- Ubuntu 12.04 development server installation and running (through virtualenv, Vagrant and `manage.py runserver`)
- project building (static assets, production bundle compilation)
- project launch on the production Vagrant instance with nginx-supervisor-gunicorn deployment scheme

We use here a nice way to deploy Django in production:
- `nginx` as a front server which directly handles static files
- `gunicorn` as WSGI server which itself is controlled by `supervisor`
- dependencies are described in `requirements.txt` and about to be installed into `virtualenv`

The configs are [Vagrantfile](Vagrantfile) and [django_vagrant_core_scripts](django_vagrant_core_scripts)
directory content.

How to use
----------

Install VirtualBox and Vagrant on your host.
Then setup and launch the virtual dev/prod server with either of three commands

    vagrant up dev
    vagrant up prod
    vagrant up dev+prod

That begs Vagrant to download Ubuntu 12.04 and to install all necessary Debian packages and Python libraries
into it. This activity can last about 15 minutes for the first time.

Dev/prod
--------

A dev server is one that serves files from your root repository directory which is mapped in virtual
server to `/vagrant/`.  The server is run by `python3 manage.py runserver` in `DEBUG == True` mode.
It is restarted after every fail by supervisor.

You can access the home page in your host machine's browser on http://127.0.0.1:8042/

A prod server is one that serves files from an unpacked package within `/home/vagrant/` directory.
The front server is nginx which serves static assets and redirects dynamic calls to gunicorn. 
Gunicorn is restarted by `supervisor`. After `vagrant up prod` you can rebuild the prod Django instance:

    vagrant ssh
    /vagrant/django_vagrant_core_scripts/launch_prod_debug_true.sh

or

    vagrant ssh
    /vagrant/django_vagrant_core_scripts/launch_prod_debug_false.sh

You can access the home page of the prod instance in your host machine's browser on http://127.0.0.1:8066/

The two instances - dev and prod - don't interfere with each other: they use different directories and different
database. So they can be both launched on a single virtual machine.

Notes
-----

1. I know that launching prod server via Vagrant is a strange idea and I myself don't do that. Here by "prod server"
    I rather mean "stage server". But I suggest you to setup your prod server by copying the setup of stage server.

2. I assume the following workflow for launching new version on prod:

    vagrant up dev  # or dev+prod
    vagrant ssh
    /vagrant/django_vagrant_core_scripts/build_prod.sh
    exit

    # then on the host machine
    scp builds/django_vagrant_VERSION.tar.gz vagrant@deploymentserver.com:/home/vagrant/
    ssh vagrant@deploymentserver.com
    tar xvf django_vagrant_VERSION.tar.gz
    sudo ./launch_prod.sh

3. When I configured this repo I just had no time to learn the great and wise debian packaging system, sorry.


Details of the workflow
-----------------------

Vagrant maps your project's directory to Ubuntu server's `/vagrant/` directory. You can `vargant ssh` to
the Vagrant server.

You can call `vagrant suspend` or `vagrant halt`. Then again type `vagrant up` to resume the machine.

Two types of server can be run on a single Ubuntu server: dev server and staging server.

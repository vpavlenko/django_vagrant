Scaffold for Django application: the goal
-----------------------------------------

Why deploying Django is that hard for every novice? Can we fix that?

The major goal of this repo is to scaffold and automate three things:
- installation and running of Ubuntu 12.04 development server, agnostic of your host system
    (here I use virtualenv, Vagrant and `manage.py runserver` against sqlite3 database)
- project packaging (production package packaging, maybe one day I'll add static assets compilation)
- launch of the stage-test-prod instance with nginx-supervisor-gunicorn-mysql deployment scheme

I use here a known-to-be-nice way to deploy Django in production:
- `nginx` as a front server which directly handles static files
- `gunicorn` as WSGI server for dynamic content which itself is controlled by `supervisor`
- dependencies are described in `requirements.txt` and about to be installed into `virtualenv`

The configs are [Vagrantfile](Vagrantfile) and [django_vagrant_core_scripts](django_vagrant_core_scripts)
directory content.

How to use
----------

Install VirtualBox and Vagrant on your host.
Then setup and launch the virtual dev/prod server with either of three commands

    vagrant up dev  # if you are a developer
    vagrant up prod  # if you are a deployer
    vagrant up dev+prod  # if you are just like me

These commands beg Vagrant to download Ubuntu 12.04 and to install all necessary Debian packages and Python libraries
into it. The installation can last about 15 minutes for the first time.

Dev/prod
--------

A dev server is one that serves Django files from your root repository directory which is mapped
to `/vagrant/` on a local virtual machine. The server is run by `python3 manage.py runserver`
in `DEBUG == True` mode and against the sqlite3 database. It is restarted after every fail by supervisor.
Dev database admin credentials are set to:

    login: admin
    password: 42

You can access the home page of the dev instance via your host machine's browser on http://127.0.0.1:8042/

A prod server is one that serves files from an unpacked package within `/home/vagrant/` directory.
The front server is nginx which serves static assets and redirects dynamic requests to gunicorn. 
Gunicorn is restarted by `supervisor`. The prod database is MySQL

After you setup the virtual machine with `vagrant up prod`, you can relaunch the prod Django instance:

    vagrant ssh
    /vagrant/django_vagrant_core_scripts/launch_prod_debug_true.sh

or

    vagrant ssh
    /vagrant/django_vagrant_core_scripts/launch_prod_debug_false.sh

Relaunch is done via packing and unpacking project files. Every package is saved to `builds/`.

You can access the home page of the prod instance in your host machine's browser on http://127.0.0.1:8066/

The two instances - dev and prod - don't interfere with each other: they use different directories and different
databases. So they can be both launched on a single virtual machine. 

Both dev/prod instances are launched with uid == gid == vagrant. 

Notes
-----

1. I know that controlling prod server via Vagrant is a strange idea and I myself don't do that. Throughout this
    scaffold by "prod server" I rather mean "stage server" ("test server"). But I suggest you to setup your
    prod server by copying the setup of stage server. My main goal was to give you a working example
    of a stable Django deployment.

2. I assume the following workflow for deploying new version to your production server:

    vagrant up dev  # or dev+prod
    vagrant ssh

    # on the virtual machine
    /vagrant/django_vagrant_core_scripts/build_prod.sh  # builds the package with venv/, collected_static/ and code/
    exit

    # then on the host machine
    scp packages/django_vagrant_VERSION.tar.gz vagrant@deploymentserver.com:/home/vagrant/
    ssh vagrant@deploymentserver.com
    tar xvf django_vagrant_VERSION.tar.gz
    sudo ./launch_prod.sh

3. When I configured this repo I just had no time to learn the great and wise debian packaging system. Maybe I'll do
    it later.

4. The virtual machine is set up to use 2 Gb of your memory.  If that sucks for you then please excuse me
and edit [Vagrantfile](Vagrantfile), line

    vb.customize ["modifyvm", :id, "--memory", "2048"]

Vagrant hints
-------------

You can call `vagrant suspend` or `vagrant halt` when you do want to pause or stop the running virtual machine.
After doing that you just type `vagrant up` to resume the machine.

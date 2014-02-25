Example application with Django and Vagrant
===========================================

The application is a scaffold for one good way to deploy Django in production:
- `nginx` as a front server
- `gunicorn` as WSGI server which itself is controlled by `supervisor`
- dependencies are described in `requirements.txt` and about to be installed into `virtualenv`

The configs are [Vagrantfile](Vagrantfile) and [vagrant_conf](vagrant_conf) directory content.
Launch the machine with

    vagrant up

After the download and installation (about 15 minutes) find the server on http://127.0.0.1:8042/
You can call `vagrant suspend` or `vagrant halt`. Then again type `vagrant up` to resume the machine.

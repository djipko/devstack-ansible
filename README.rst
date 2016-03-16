devstack-ansible
================

Ansible role and playbooks for deploying a working devstack lab (for more
information on devstack see `here`_). Allows deployment of a multinode,
Neutron-backed deployment with Nova set up to use shared storage and shared
ssh keys to facilitate live migration.

Was tested with VMs based on Fedora23 cloud image, and the main playbook
(devstack.yml) expects to be using a user called `fedora`

Usage
-----

First clone this repo and install Ansible::

    $ pip install ansible

you may want to do this in a virtualenv for maximum isolation.

Next, you want to generate a keypair that will be set up on all of the hosts.
This is required for live migration to work as password-less ssh::

    $ ssh-keygen # Make sure you save the keypair to the top directory

In case your keys are named differently than `id_rsa` and `id_rsa.pub` you will
need to let Ansible know where to look by overriding the `ssh_private_key` and
`ssh_public_key` variables by passing them on the command line (see below).

Finally, you want to install the roles we depend on::

    $ ansible-galaxy install -r requirements.yml -p ./roles/

And create a hosts file with the expected groups `contorller` and `compute`::

    $ cat << EOF > devstack_hosts
    [controller]
    ctrl-vm

    [compute]
    cpu1
    cpu2
    cpu3
    EOF

Now we can fire off the main playbook and hopefully have a working setup in no
time::

    $ ansible-playbook devstack.yml -i devstack-hosts --extra-vars="ssh_public_key=$KEYNAME.pub ssh_private_key=$KEYNAME"

you can omit the --extra-vars part as described above.

Some more information
---------------------

This is meant to be used on disposable VMs, as it runs the ./stack.sh script
which makes a lot of non-(easily)-reversible changes to hosts. This is really
meant for testing and developing OpenStack, and is not intended for any kind of
production use.

To drive the point home - I included a handy script `provision_testvm.sh` that
lets you quickly spin up test VMs on your favourite (actual production)
OpenStack cloud, that you tear down as soon as your done.

.. _here: www.devstack.org

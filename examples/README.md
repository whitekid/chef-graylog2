Graylog2 Chef Repo
==================

This repository contains the necessary cookbooks to install and configure Graylog2.

Testing with Vagrant
-------

This will get you VM with a working Graylog2 installation.

  1) Install vagrant

    gem install vagrant

  2) Install VirtualBox

  3) Launch & provision VM

    vagrant up    

Enjoy your running Graylog2 instance (load http://127.0.0.1:8080 in a browser to  
access Graylog2). Also, check out 'vagrant ssh' to log in to VM and 'vagrant 
provision' to kick of the chef run again).  If you want to edit any of the Chef 
attributes for Graylog2 configuration, do so in the Vagrantfile.

Contributing
------------

Please contribute updates, additions or documentation changes.  If you don't here back briefly,
feel free to pester continuously.

### Repo contributors

  * jbz
  * nstielau
  * portertech
  * agoddard
  * spazm

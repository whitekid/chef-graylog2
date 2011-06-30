Graylog2 Chef Repo
==================

This repository contains the necessary cookbooks to install and configure Graylog2.

Installing
----------

### Installing with Chef Server

  1) Copy these cookbooks into your repository as needed
  2) Upload cookbooks to your chef-server
  3) Add the appropriate recipes to a node's run list, and converge.

Enjoy your running Graylog2 instance

### Installing with Chef Solo

  1) Clone this repository
  2) write a solo.rb file:

    file_cache_path "/var/chef-solo"
    # point to graylog2 cookbooks!
    cookbook_path "/var/chef-solo/cookbooks"

  3) Write a json file with runlist and attributes

    {
      "graylog2": {
        "send_stream_subscriptions": false
      },
      "run_list": [ "recipe[graylog2::server]",
                    "recipe[graylog2::apache]"]
    }

  4) Run chef-solo:

    chef-solo -c ~/solo.rb -j ~/node.json

Enjoy your running Graylog2 instance

### Installing with Chef Vagrant

  1) Install vagrant

    gem install vagrant

  2) Install VirtualBox

  3) Launch & provision VM

    vagrant up

Enjoy your running Graylog2 instance (check 127.0.0.1:8080 to access Graylog2)


Contributing
------------

Please contribute updates, additions or documentation changes.



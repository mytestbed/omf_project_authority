
OMF Project Authority
=====================

This directory contains the implementations of simple OMF Project Authority which 
allows for the manipulation and observation of users, projects, and hteir relationships.

Installation
------------

At this stage the best course of action is to clone the repository

    % git clone https://github.com/mytestbed/omf_project_authority.git
    % cd omf_project_authority
    % sudo apt-install sqlite3-dev  # for Debian/Ubuntu systems
    % bundle install --path vendor
    
Starting the Service
--------------------

To start a project authority with a some pre-populated resources ('--test-load-state') from this directory, run the following:

    % cd omf_project_authority
    % bundle exec bin/omf_project_authority --disable-https --test-load-state --dm-auto-upgrade start
    
which should result in something like:

    DEBUG Server: options: {:app_name=>"exp_server", :chdir=>"/Users/max/src/gimi_experiment_service", :environment=>"development", :address=>"0.0.0.0", :port=>8002, :timeout=>30, :log=>"/tmp/exp_server_thin.log", :pid=>"/tmp/exp_server.pid", :max_conns=>1024, :max_persistent_conns=>512, :require=>[], :wait=>30, :rackup=>"/Users/max/src/gimi_experiment_service/lib/gimi/exp_service/config.ru", :static_dirs=>["./resources", "/Users/max/src/omf_sfa/lib/omf_base/thin/../../../share/htdocs"], :static_dirs_pre=>["./resources", "/Users/max/src/omf_sfa/lib/omf_base/thin/../../../share/htdocs"], :handlers=>{:pre_rackup=>#<Proc:0x007ffd0ab91388@/Users/max/src/gimi_experiment_service/lib/gimi/exp_service/server.rb:83 (lambda)>, :pre_parse=>#<Proc:0x007ffd0ab91360@/Users/max/src/gimi_experiment_service/lib/gimi/exp_service/server.rb:85 (lambda)>, :pre_run=>#<Proc:0x007ffd0ab91338@/Users/max/src/gimi_experiment_service/lib/gimi/exp_service/server.rb:94 (lambda)>}, :dm_db=>"sqlite:///tmp/gimi_test.db", :dm_log=>"/tmp/gimi_exp_server-dm.log", :load_test_state=>true, :dm_auto_upgrade=>true}
    INFO Server: >> Thin web server (v1.3.1 codename Triple Espresso)
    DEBUG Server: >> Debugging ON
    DEBUG Server: >> Tracing ON
    INFO Server: >> Maximum connections set to 1024
    INFO Server: >> Listening on 0.0.0.0:8004, CTRL+C to stop
    

Testing REST API
----------------

If you started the service with the '--test-load-state' option, the service got preloaded with a few
resources. To list all users:

    $ curl http://localhost:8004/users
    [
      {
        "uuid": "fcae7f37-7f41-5b58-b22b-ed741c84ded3",
        "href": "http://221.199.209.233:8004/users/fcae7f37-7f41-5b58-b22b-ed741c84ded3",
        "name": "adam",
        "type": "user"
      },
      {
        "uuid": "ef45d397-0411-5f5e-8940-9bdbdef3958b",
        "href": "http://221.199.209.233:8004/users/ef45d397-0411-5f5e-8940-9bdbdef3958b",
        "name": "bob",
        "type": "user"
      }
    ]
    
To get a full listing for user 'bob':

    % curl http://localhost:8004/users/bob?_level=3
    {
      "type": "user",
      "uuid": "ef45d397-0411-5f5e-8940-9bdbdef3958b",
      "href": "http://221.199.209.233:8004/users/ef45d397-0411-5f5e-8940-9bdbdef3958b",
      "name": "bob",
      "expiration": "2014-07-13T04:54:57+00:00",
      "creation": "2014-01-14T04:54:57+00:00",
      "email": "bob@acme.com",
      "project_memberships": [
        {
          "uuid": "0c40b34f-b1a2-4766-a742-94817acd4ec0",
          "href": "http://221.199.209.233:8004/project_members/0c40b34f-b1a2-4766-a742-94817acd4ec0",
          "name": "r24341060",
          "type": "project_member",
          "project": "http://221.199.209.233:8004/projects/f8092fe6-dd4c-5c7e-a01c-85c542e50ddf",
          "user": "http://221.199.209.233:8004/users/ef45d397-0411-5f5e-8940-9bdbdef3958b",
          "role": "member"
        },
        {
          "uuid": "f35b6991-b03f-4d86-9507-e2a8bfa96324",
          "href": "http://221.199.209.233:8004/project_members/f35b6991-b03f-4d86-9507-e2a8bfa96324",
          "name": "r26160500",
          "type": "project_member",
          "project": "http://221.199.209.233:8004/projects/0b01a876-8755-568d-8e24-fe0197318e03",
          "user": "http://221.199.209.233:8004/users/ef45d397-0411-5f5e-8940-9bdbdef3958b",
          "role": "leader"
        }
      ],
      "certificate": "http://221.199.209.233:8004/users/ef45d397-0411-5f5e-8940-9bdbdef3958b/cert"
    }    

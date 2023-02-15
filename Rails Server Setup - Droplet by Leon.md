## Connect to server
```
ssh root@<IPv4>
(See email for the root PW)
```

## Rails Installation (Ubuntu 20.04)
```
sudo apt install curl
curl -sL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install git-core zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev nodejs yarn
```

## RVM
```
sudo apt-add-repository -y ppa:rael-gc/rvm
sudo apt-get update
sudo apt-get install rvm
echo 'source "/etc/profile.d/rvm.sh"' >> ~/.bashrc
```

## Postgresql
```
sudo apt-get install postgresql postgresql-client
sudo apt-get install libpq-dev

sudo -u postgres psql postgres

postgres=# CREATE USER "<app_psql_usr_name>";
postgres=# \password <app_psql_usr_name>
-> Enter <app_psql_pw> (e.g. generate a 64 bytes pw)
postgres=# CREATE DATABASE "<app_psql_db_name>" owner="<app_psql_usr_name>";
postgres=# \q

# Open Postgres pg_hba.conf file (or show path in psql console with 'SHOW hba_file;')
sudo vi /etc/postgresql/14/main/pg_hba.conf


# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   <app_psql_db_name>    <app_psql_usr_name>          md5

sudo systemctl restart postgresql
```

## Custom Ubuntu User
```
adduser deployer
-> enter pw
adduser deployer sudo
```

## Login with new user
```
su deployer
```

## Berechtigung
```
sudo usermod -a -G rvm deployer
sudo mkdir /var/www
sudo chown deployer /var/www
```

**Login with Custom User**
## Rvm
```
echo 'source "/etc/profile.d/rvm.sh"' >> ~/.bashrc
source ~/.bashrc
sudo chmod -R a+xwr /usr/share/rvm
rvm pkg install openssl
rvmsudo rvm install ruby 3.1.2 --with-openssl-dir=$HOME/.rvm/usr
rvm --default use 3.1.2
mkdir /var/www/<project_name>
mkdir /var/www/<project_name>/shared
mkdir /var/www/<project_name>/shared/config
sudo vi /var/www/<project_name>/.ruby-gemset
-> enter: <project_name>

cd /var/www/<project_name>
gem install bundler
```

## Git
```
git config --global color.ui true
git config --global user.name "Yoshi20"
git config --global user.email "jascha_haldemann@hotmail.com"
ssh-keygen -t rsa -b 4096 -C "jascha_haldemann@hotmail.com"
-> default file & no PW

cat ~/.ssh/id_rsa.pub
-> add the ssh key to your github account
```

## Deploy Process (Mina)
```
# Add to gemfile
gem 'mina'

bundle

# Copy master.key to shared dir
scp config/master.key deployer@<IPv4>:/var/www/<project_name>/shared/config

# Copy database.yml to shared dir
scp config/database.yml deployer@<IPv4>:/var/www/<project_name>/shared/config
```

.config/deploy.rb
```
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
require 'mina/rvm'    # for rvm support. (https://rvm.io)
set :rvm_use_path, '/usr/share/rvm/scripts/rvm'

set :application_name, '<project_name>'
set :domain, '<IPv4>'
set :deploy_to, '/var/www/<project_name>'
set :repository, 'git@github.com:<user>/<project_name>.git'
set :branch, 'main'

# Optional settings:
set :user, 'deployer'          # Username in the server to SSH to.

set :rails_env, 'production'

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
set :shared_files, fetch(:shared_files, []).push('config/master.key', 'config/database.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use', 'ruby-3.1.2@<project_name>'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  #command %{rvm install ruby-3.1.2}
  #command %{gem install bundler}
end

desc "Deploys the current version to the server."
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    #invoke 'stop_delayed_job_worker'
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %{mkdir -p tmp/}
        command %{touch tmp/restart.txt}
        #invoke 'remote_environment'
        #invoke 'start_delayed_job_worker'
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

task :stop_delayed_job_worker do
  comment 'Stop current delayed_job worker'
  command %{RAILS_ENV=production /var/www/<project_name>/current/bin/delayed_job stop}
end

task :start_delayed_job_worker do
  comment 'Start new delayed_job worker'
  command %{RAILS_ENV=production /var/www/<project_name>/current/bin/delayed_job start}
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs

```

## Install NGINX & Passenger
https://gorails.com/deploy/ubuntu/20.04
```
# Install
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger focal main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update
sudo apt-get install -y nginx-extras libnginx-mod-http-passenger

if [ ! -f /etc/nginx/modules-enabled/50-mod-http-passenger.conf ]; then sudo ln -s /usr/share/nginx/modules-available/mod-http-passenger.load /etc/nginx/modules-enabled/50-mod-http-passenger.conf ; fi
sudo ls /etc/nginx/conf.d/mod-http-passenger.conf

# Update Ruby Path
sudo vim /etc/nginx/conf.d/mod-http-passenger.conf
# Change -> passenger_ruby /usr/bin/passenger_free_ruby;
# To -> passenger_ruby /usr/share/rvm/rubies/ruby-3.1.2/bin/ruby;

sudo service nginx start
```

## Configure NGINX
```
# Configuration
# (The files in sites-enabled should just be links to the "real" files in sites-available. You should only edit the ones in sites-available)

sudo rm /etc/nginx/sites-enabled/default

sudo vim /etc/nginx/sites-available/<project_name>.conf
-> copy & paste:
server {
  listen 80;
  listen [::]:80;

  server_name _;
  root /var/www/<project_name>/current/public;

  passenger_enabled on;
  passenger_app_env production;

  location /cable {
    passenger_app_group_name <project_name>_websocket;
    passenger_force_max_concurrent_requests_per_process 0;
  }

  # Allow uploads up to 100MB in size
  client_max_body_size 100m;

  location ~ ^/(assets|packs) {
    expires max;
    gzip_static on;
  }
}

sudo ln -s /etc/nginx/sites-available/<project_name>.conf /etc/nginx/sites-enabled/<project_name>.conf

# Full Restart
sudo service nginx stop
sudo service nginx start
```

## Set ENVs
```
vim ~/.bashrc
# Add at the top of the file:
export <PROJECT_NAME>_DATABASE_PASSWORD=<app_psql_pw>
export ...
source ~/.bashrc
```

## First deployment
```
mina setup
mina deploy
```

## (In case of nginx error)
```
sudo cat /var/log/nginx/error.log

# If passenger does not start due to libssl
wget http://nz2.archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.17_amd64.deb
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2.17_amd64.deb
```

## HTTPs
```
https://certbot.eff.org/instructions?ws=nginx&os=ubuntufocal

sudo apt install snapd
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

sudo certbot certonly --nginx

# Sample Output:
# Certificate is saved at: /etc/letsencrypt/live/<project_name>.ch/fullchain.pem
# Key is saved at: /etc/letsencrypt/live/<project_name>.ch/privkey.pem


# HTTPS Conf (and redirect from http to https)
server {
    listen 80 default_server;
    server_name <project_name>.ch;
    return 301 https://$server_name$request_uri;
}

server {
  listen 443 ssl;
  server_name <project_name>.ch
  server_tokens off;
	charset utf-8;

  ssl_certificate /etc/letsencrypt/live/<project_name>.ch/fullchain.pem
  ssl_certificate_key /etc/letsencrypt/live/<project_name>.ch/privkey.pem

  root /var/www/<project_name>/current/public;

  passenger_enabled on;
  passenger_app_env production;

  location /cable {
    passenger_app_group_name <project_name>_websocket;
    passenger_force_max_concurrent_requests_per_process 0;
  }

  # Allow uploads up to 100MB in size
  client_max_body_size 100m;

  location ~ ^/(assets|packs) {
    expires max;
    gzip_static on;
  }
}
```

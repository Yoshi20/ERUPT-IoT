require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
require 'mina/rvm'    # for rvm support. (https://rvm.io)
set :rvm_use_path, '/usr/share/rvm/scripts/rvm'

set :application_name, 'erupt-iot'
set :domain, '5.75.145.55'
set :deploy_to, '/var/www/erupt-iot'
set :repository, 'git@github.com:Yoshi20/ERUPT-IoT.git'
set :branch, 'prod'

# Optional settings:
set :user, 'deployer'          # Username in the server to SSH to.

set :rails_env, 'production'

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
set :shared_files, fetch(:shared_files, []).push('config/master.key', 'config/application.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use', 'ruby-3.1.2@erupt-iot'
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
    # invoke 'remote_environment'
    # invoke 'stop_delayed_job_worker'
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
        # invoke 'remote_environment'
        # invoke 'start_delayed_job_worker'
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

task :stop_delayed_job_worker do
  comment 'Stop current delayed_job worker'
  command %{RAILS_ENV=production /var/www/erupt-iot/current/bin/delayed_job stop}
end

task :start_delayed_job_worker do
  comment 'Start new delayed_job worker'
  command %{RAILS_ENV=production /var/www/erupt-iot/current/bin/delayed_job start}
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs

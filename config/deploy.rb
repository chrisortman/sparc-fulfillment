# Copyright © 2011-2019 MUSC Foundation for Research Development~
# config valid only for current version of Capistrano
lock '3.11.0'

set :application, 'fulfillment'
set :repo_url, 'ssh://git@git.its.uiowa.edu:7999/icts/sparc-fulfillment.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/html/sparc/fulfillment'

# Default value for :scm is :git - Depreciation notice from capistrano
#set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/faye.yml', 'config/sparc_db.yml', 'config/klok_db.yml', '.env')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', ENV.fetch('DOCUMENTS_FOLDER'), 'public/system/imports')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # restart Faye server
      within current_path do
        execute :bundle, "exec thin -C config/faye.yml stop"
        execute :bundle, "exec thin -C config/faye.yml start"
      end
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

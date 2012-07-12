set :stages, %w(cs)
set :default_stage, "cs"
require 'capistrano/ext/multistage'

load 'deploy/assets'

set :default_environment, {
  'PATH' => "/usr/local/rvm/gems/ruby-1.9.3-p0/bin:/usr/local/rvm/gems/ruby-1.9.3-p0@global/bin:/usr/local/rvm/rubies/ruby-1.9.3-p0/bin:/usr/local/rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
  'RUBY_VERSION' => 'ruby-1.9.3-p0',
  'GEM_HOME'     => '/usr/local/rvm/gems/ruby-1.9.3-p0',
  'GEM_PATH'     => '/usr/local/rvm/gems/ruby-1.9.3-p0:/usr/local/rvm/gems/ruby-1.9.3-p0@global',
  'BUNDLE_PATH'  => '/usr/local/rvm/gems/ruby-1.9.3-p0/'  # If you are using bundler.
}

default_run_options[:pty] = true

set :rake, 'bundle exec rake'

set :scm, "git"

set :application, "paperPiazza"
set :repository,  "git@github.com:iamadawra/paperPiazza"
set :user, "ubuntu"

ssh_options[:forward_agent] = true

set :branch, "master"
set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/#{application}"

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

task :uname do
  run "uname -a"
end

namespace :deploy do
  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end
 task :symlink_db_config, :roles => :app do
    run <<-CMD
      ln -nfs #{release_path}/config/database.yml.pg #{release_path}/config/database.yml
    CMD
  end 
end
after "deploy:symlink","deploy:symlink_db_config"

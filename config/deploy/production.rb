set :application, "lincomp"

set :scm, :git
set :repository, "git://github.com/psy-q/stizun.git"
set :branch, "master"
set :deploy_via, :remote_cache
set :keep_releases, 2 

set :use_sudo, false
set :deploy_to, "/home/lincomp/production"


set :db_config, "/home/lincomp/database_prod.yml"
set :email_config, "/home/lincomp/email.yml"
set :custom_directory, "/home/lincomp/custom"

role :web, "lincomp@www.lincomp.ch"                          # Your HTTP server, Apache/etc
role :app, "lincomp@www.lincomp.ch"                          # This may be the same as your `Web` server
role :db,  "lincomp@www.lincomp.ch", :primary => true # This is where Rails migrations will run

task :link_config do
  on_rollback { run "rm #{release_path}/config/database.yml" }
  run "rm #{release_path}/config/database.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "rm #{release_path}/config/email.yml"
  run "ln -s #{email_config} #{release_path}/config/email.yml"

  run "sed -i 's,config.action_mailer.perform_deliveries = false,config.action_mailer.perform_deliveries = true' #{release_path}/config/environments/production.rb"
end

task :link_files do
    run "ln -s #{deploy_to}/#{shared_dir}/tmp/downloads #{release_path}/tmp/downloads"
    run "ln -s #{deploy_to}/#{shared_dir}/uploads #{release_path}/public/uploads"
end

task :install_gems do
  run "cd #{release_path} && RAILS_ENV=production bundle install --deployment --without cucumber test development"
end

task :configure_sphinx do
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake ts:conf && RAILS_ENV=production bundle exec rake ts:reindex"
end

task :restart_sphinx do
  run "cd #{release_path} && RAILS_ENV=production bundle exec rake ts:restart"
end


task :overwrite_custom do
  run "cd #{release_path} && rm -rf #{release_path}/custom"
  run "ln -s #{custom_directory} #{release_path}/custom"
end



namespace :deploy do
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "cd #{release_path} && RAILS_ENV='production' bundle exec rake db:migrate"
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end

   task :after_deploy do
     cleanup
   end 
end

after "deploy:symlink", :link_config
after "link_config", "install_gems"
after "link_config", "link_files"
after "install_gems", "configure_sphinx"
after "install_gems", "overwrite_custom"
after "configure_sphinx", "restart_sphinx"


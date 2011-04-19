set :application, "lincomp"

set :scm, :git
set :repository, "git://github.com/psy-q/stizun.git"
set :branch, "experimental"
set :deploy_via, :remote_cache
set :keep_releases, 2 

set :use_sudo, false
set :deploy_to, "/home/web/test.lincomp.org/test"


set :db_config, "/home/web/test.lincomp.org/database_test.yml"
set :stizun_config, "/home/web/test.lincomp.org/stizun.yml"

role :web, "lincomp@test.lincomp.org"                          # Your HTTP server, Apache/etc
role :app, "lincomp@test.lincomp.org"                          # This may be the same as your `Web` server
role :db,  "lincomp@test.lincomp.org", :primary => true # This is where Rails migrations will run

task :link_config do
  on_rollback { run "rm #{release_path}/config/database.yml" }
  run "rm #{release_path}/config/database.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "rm #{release_path}/config/stizun.yml"
  run "ln -s #{stizun_config} #{release_path}/config/stizun.yml"

  run "rm -r #{release_path}/test"
  run "ln -s #{release_path}/public #{release_path}/test"
  run "sed -i 's:config.middleware.use.*::' #{release_path}/config/environments/production.rb"
  run "sed -i 's,default_from_email:.*,default_from_email: \"rca@psy-q.ch\",' #{release_path}/config/stizun.yml"
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


namespace :deploy do
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end

   task :after_deploy do
     cleanup
   end 
end

after "deploy:symlink", :link_config
after "link_config", "link_files"
after "link_config", "install_gems"
after "install_gems", "configure_sphinx"
after "configure_sphinx", "restart_sphinx"

namespace :app do
  task :deploy do
    puts `git pull`
    puts `git checkout-index -a -f --prefix=/var/www/simul8-experiments.pangel.fr/`
    puts `/etc/init.d/thin restart`
    puts "Deploy complete"
  end
end
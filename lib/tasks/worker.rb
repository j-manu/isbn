namespace :resque do
  task :start do
    Resque.redis.namespace = :isbn
    Rake::Task['resque:work'].invoke
  end
end

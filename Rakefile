load 'environment.rb'
require 'csv'
task :run_crawl do
  Crawler.perform_async(ENV['LISTSERV'])
end

task :monitor do
  require 'sidekiq/web'
  app = Sidekiq::Web
  app.set :environment, :production
  app.set :bind, '0.0.0.0'
  app.set :port, 9494
  app.set :server, :webrick
  app.run!
end

task :generate_geo_export do
  offset = 0
  limit = 1000
  t_count = Tweet.count
  while offset < t_count
    GenLocExtract.perform_async(offset)
  end
  offset += limit
end
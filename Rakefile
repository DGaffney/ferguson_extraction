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
  gg = CSV.open("geo_export.csv", "w")
  gg << ["user_id", "tweet_id", "screen_name", "mentioned_users", "mentioned_topics", "location", "lat", "lon"]
  offset = 0
  limit = 1000
  set = Tweet.fields(:user_id, :twitter_id, :categories, :screen_name, :content).limit(limit).offset(offset)
  while !set.empty?
    set.each do |t|
      location = UserProfile.fields("content.location").first(user_id: t.user_id).content.location.downcase.strip rescue nil
      lat, lon = nil, nil
      if !location.nil?
        begin
          binding.pry if location == "atlanta, ga"
          set = GeoResult.first(location: location).content.point.coordinates
          lat = set.first
          lon = set.last
        rescue
          puts "Couldn't find: #{location}"
        end
      end
      print "."
      gg << [t.user_id, t.twitter_id, t.screen_name, t.categories.collect(&:term).join("\t"), t.content.content.to_s.extract_screen_names.join("\t"), location, lat, lon]
    end
    offset+=limit
    set = Tweet.fields(:user_id, :twitter_id, :categories, :screen_name, :content).limit(limit).offset(offset)
  end
  gg.close
end
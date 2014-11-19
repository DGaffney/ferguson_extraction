class GenLocExtract
  include Sidekiq::Worker
  def perform(offset)
    # gg << ["user_id", "tweet_id", "screen_name", "mentioned_users", "mentioned_topics", "location", "lat", "lon"]
    gg = CSV.open(File.dirname(__FILE__)+"/../geo_export/geo_export_#{offset}.csv", "w")
    set = Tweet.fields(:user_id, :twitter_id, :categories, :screen_name, :content).limit(limit).offset(offset)
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
    gg.close
  end
end
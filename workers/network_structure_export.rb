class NetworkStructureExport
  include Sidekiq::Worker
  def perform(rows, pid)
    attrs = ["In-Degree", "Out-Degree", "Degree", "Weighted Degree", "Weighted In-Degree", "Weighted Out-Degree", "Eccentricity", "Closeness Centrality", "Betweenness Centrality", "Authority", "Hub", "Component ID", "PageRank", "Clustering Coefficient", "Eigenvector Centrality", "Strongly-Connected ID"]
    gg = CSV.open(File.dirname(__FILE__)+"/../export/geo_export_#{pid}.csv", "w")
    set = Tweet.fields(:user_id, :twitter_id, :categories, :screen_name, :content).where(:screen_name => rows.collect(&:Id))
    set.each do |t|
      location = UserProfile.fields("content.location").first(user_id: t.user_id).content.location.downcase.strip rescue nil
      lat, lon = nil, nil
      if !location.nil?
        begin
          # binding.pry if location == "atlanta, ga"
          set = GeoResult.first(location: location).content.point.coordinates
          lat = set.first
          lon = set.last
        rescue
          puts "Couldn't find: #{location}"
        end
      end
      print "."
      row = rows.select{|x| x["Id"] == t.screen_name}.first
      result = [t.user_id, t.twitter_id, t.screen_name, t.categories.collect(&:term).join("\t"), t.content.content.to_s.extract_screen_names.join("\t"), location, lat, lon]
      attrs.each do |att|
        result << row[att]
      end
      gg << result
    end
    gg.close
  end
end

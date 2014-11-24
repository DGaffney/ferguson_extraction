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
  limit = 10000
  t_count = Tweet.count
  while offset < t_count
    GenLocExtract.perform_async(offset)
    offset += limit
  end
end

task :first_pass_enrich do 
  ["data/out_01pc.csv", "data/out_1pc.csv", "data/out_10pc.csv"].each do |filename|
    gg = CSV.read(filename)
    user_details = Hash[UserProfile.where(user_id: gg.collect(&:first).collect(&:to_i)).collect{|x| [x.content.id_str, x.content]}]
    tweet_times = Hash[Tweet.where(twitter_id: gg.collect{|x| x[1].to_i}).fields(:twitter_id, :published).collect{|x| [x.twitter_id.to_s, x.published.to_i]}]
    dataset = []
    gg.each_with_index do |row, i|
    gg[i] = row[0..7]
    end
    dataset << ["user_id", "tweet_id", "screen_name", "mentioned_tags", "mentioned_users", "location", "lat", "lon", "created_at", "favourites_count", "followers_count", "friends_count", "lang", "listed_count", "location", "statuses_count", "time_zone", "utc_offset"]
    gg.each do |row|
      row << Time.parse(user_details[row.first].created_at).to_i rescue nil
      row << user_details[row.first].favourites_count rescue nil
      row << user_details[row.first].followers_count rescue nil
      row << user_details[row.first].friends_count rescue nil
      row << user_details[row.first].lang rescue nil
      row << user_details[row.first].listed_count rescue nil
      row << user_details[row.first].location rescue nil
      row << user_details[row.first].statuses_count rescue nil
      row << user_details[row.first].time_zone rescue nil
      row << user_details[row.first].utc_offset rescue nil
      dataset << row
    end
    dataset.each_with_index do |row, i|
      if i == 0
        dataset[i] << "tweet_created_at"
      else
        dataset[i] << tweet_times[row[1]]
      end
    end
    csv = CSV.open(filename.split("/").join("/enriched_"), "w")
    dataset.each do |row|
      csv << row
    end
    csv.close
  end
end

task :second_pass_enrich do
  ["data/enriched_out_01pc.csv", "data/enriched_out_1pc.csv", "data/enriched_out_10pc.csv"].each do |filename|
    gg = CSV.read(filename)
    keys = gg.first
    dataset = []
    gg[1..-1].each do |row|
      dataset << Hash[keys.zip(row)]
    end
    politicians_raw = CSV.read("data/politicians.csv")
    keys = politicians_raw.first
    politicians = {}
    i = 0
    politicians_raw[1..-1].each do |row|
      politicians[row[0].downcase] = Hash[keys.zip(row)]
    end
    journalists = File.read("data/journalists.csv").split("\n").collect(&:downcase)
    dataset.each do |row|
      binding.pry if i == 142
            puts i
      row.politician_count = 0
      row.journalist_count = 0
      row.avg_politician_distance = []
      row.mentioned_users.split("\t").collect(&:downcase).each do |u|
        if politicians[u]
          row.politician_count += 1
          if row.lat && row.lon
            row.avg_politician_distance << Geocoder::Calculations.distance_between([politicians[u].lat,politicians[u].lon], [row.lat,row.lon])
          end
        end
        row.journalist_count += 1 if journalists.include?(u)
      end
      i+=1
      row.avg_politician_distance = row.avg_politician_distance.average
    end
    csv = CSV.open(filename.split("/").join("/2"), "w")
    k = dataset.collect(&:keys).flatten.uniq
    csv << k
    dataset.each do |row|
      csv << k.collect{|x| row[x]}
    end
    csv.close
  end
end

task :convert_to_individual_view do
  ["data/2enriched_out_01pc.csv", "data/2enriched_out_1pc.csv", "data/2enriched_out_10pc.csv"].each do |filename|
    gg = CSV.read(filename)
    keys = gg.first
    dataset = []
    gg[1..-1].each do |row|
      dataset << Hash[keys.zip(row)]
    end
    by_user = {}
    i = 0
    dataset.each do |row|
      puts i
      # binding.pry if i == 0
      by_user[row.user_id] ||= {
        tweets: 0, 
        mentioned_tag_count: 0, 
        mentioned_user_count: 0, 
        mentioned_tag_avg: [], 
        mentioned_user_avg: [], 
        favourites_count: row.favourites_count, 
        created_at: row.created_at, 
        followers_count: row.followers_count, 
        friends_count: row.friends_count, 
        statuses_count: row.statuses_count, 
        time_zone: row.time_zone, 
        utc_offset: row.utc_offset, 
        tweet_created_at_avg: [], 
        politician_count: 0, 
        journalist_count: 0, 
        politician_avg: [], 
        journalist_avg: [], 
        politician_max_distance: [], 
        politician_min_distance: [], 
        politician_avg_distance: []
      }
      by_user[row.user_id].tweets += 1
      by_user[row.user_id].mentioned_tag_count += row.mentioned_tags.split("\t").length
      by_user[row.user_id].mentioned_user_count += row.mentioned_users.split("\t").length
      by_user[row.user_id].mentioned_tag_avg << row.mentioned_tags.split("\t").length
      by_user[row.user_id].mentioned_user_avg << row.mentioned_users.split("\t").length
      by_user[row.user_id].tweet_created_at_avg << row.tweet_created_at.to_i
      by_user[row.user_id].politician_count += row.politician_count.split("\t").length
      by_user[row.user_id].journalist_count += row.journalist_count.split("\t").length
      by_user[row.user_id].politician_max_distance << row.avg_politician_distance.to_i
      by_user[row.user_id].politician_min_distance << row.avg_politician_distance.to_i
      by_user[row.user_id].politician_avg_distance << row.avg_politician_distance.to_i
      i+=1
    end
    by_user.values.each do |row|
      row.mentioned_tag_avg = row.mentioned_tag_avg.average
      row.mentioned_user_avg = row.mentioned_user_avg.average
      row.tweet_created_at_avg = row.tweet_created_at_avg.average
      row.politician_max_distance = row.politician_max_distance.sort.last
      row.politician_min_distance = row.politician_min_distance.sort.first
      row.politician_avg_distance = row.politician_avg_distance.average
    end
    csv = CSV.open(filename.split("/").join("/2"), "w")
    k = by_user.values.collect(&:keys).flatten.uniq
    csv << k
    by_user.values.each do |row|
      csv << k.collect{|x| row[x]}
    end
    csv.close
  end
end

task :kickoff_network_structure_export do
  gg = CSV.read("ferguson_nodes.csv");false
  keys = gg.first
  dataset = []
  gg[1..-1].each do |row|
    dataset << Hash[keys.zip(row)]
  end;false
  i = 0
  dataset.each_slice(500) do |set|
    NetworkStructureExport.perform_async(set, i)
    i+=1
  end
end
module Aggregator

  def aggregate(operation)
    self.collection.aggregate(operation)
  end
  def time_series(conditions={}, key=:created_at, resolution=:hour)
    puts [
      {"$match" => conditions},
      {"$group" => { "_id" => time_series_id_by_resolution("$"+key.to_s, resolution), "count" => { "$sum" => 1 } } }
    ].inspect
    self.aggregate([
      {"$match" => conditions},
      {"$group" => { "_id" => time_series_id_by_resolution("$"+key.to_s, resolution), "count" => { "$sum" => 1 } } }
    ]).collect{|r| [r._id.values.join("-"), r["count"]]}
  end
  
  def time_series_id_by_resolution(key, resolution)
    {
      minute: {"year" => { "$year" => key }, "month" => { "$month" => key }, "day" => { "$dayOfMonth" => key }, "hour" => { "$hour" => key }, "minute" => { "$minute" => key }},
      hour: {"year" => { "$year" => key }, "month" => { "$month" => key }, "day" => { "$dayOfMonth" => key }, "hour" => { "$hour" => key }},
      day: {"year" => { "$year" => key }, "month" => { "$month" => key }, "day" => { "$dayOfMonth" => key }}
    }[resolution]
  end
end
# Tweet.time_series({}, :published, :day)
# 
# Tweet.content.content.extract_screen_names
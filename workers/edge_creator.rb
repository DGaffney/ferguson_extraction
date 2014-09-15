class EdgeCreator
  def perform(raw_data, strategy)
  end
  
  def mention_grapher(raw_data)
    raw_data.content.content.extract_screen_names.each do |name|
      Edge.first_or_create(uuid: mention_grapher_uuid(raw_data)).update_attributes(source: raw_data.screen_name, target: screen_name, attributes: [{for: "twitter_id", value: raw_data.twitter_id}, {for: "created_at", value: raw_data.published}])
    end
  end
  
  def mention_grapher_uuid(raw_data)
    [raw_data.screen_name, screen_name, raw_data.twitter_id].join("-")
  end
end
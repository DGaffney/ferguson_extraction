class EdgeCreator
  include Sidekiq::Worker
  def perform(raw_data, strategy)
    self.send(strategy, raw_data)
  end
  
  def mention_grapher(raw_data)
    raw_data.content.content.extract_screen_names.each do |name|
      Edge.first_or_create(uuid: mention_grapher_uuid(raw_data, name)).update_attributes(source: raw_data.screen_name, target: name, edge_attributes: [{for: "twitter_id", value: raw_data.twitter_id}, {for: "created_at", value: raw_data.published}])
    end
  end
  
  def mention_grapher_uuid(raw_data, screen_name)
    [raw_data.screen_name, screen_name, raw_data.twitter_id].join("-")
  end
end
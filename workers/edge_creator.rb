class EdgeCreator
  include Sidekiq::Worker
  def perform(raw_data, strategy)
    self.send(strategy, raw_data)
  end
  
  def topic_grapher(raw_data)
    raw_data.categories.collect(&:term).each do |category|
      Edge.first_or_create(uuid: topic_grapher_uuid(raw_data, category), type: "topic_grapher").update_attributes(source: raw_data.screen_name, target: category, edge_attributes: [{for: "twitter_id", value: raw_data.twitter_id}, {for: "created_at", value: raw_data.published}])
    end
  end

  def topic_grapher_uuid(raw_data, category)
    [raw_data.screen_name, category, raw_data.twitter_id].join("-")
  end

  def tag_as_mention_grapher(raw_data)
    e = Edge.find(raw_data)
    e.type = "mention_grapher"
    e.save!
  end

  def mention_grapher(raw_data)
    raw_data.content.content.extract_screen_names.each do |name|
      Edge.first_or_create(uuid: mention_grapher_uuid(raw_data, name), type: "topic_grapher").update_attributes(source: raw_data.screen_name, target: name, edge_attributes: [{for: "twitter_id", value: raw_data.twitter_id}, {for: "created_at", value: raw_data.published}])
    end
  end
  
  def mention_grapher_uuid(raw_data, screen_name)
    [raw_data.screen_name, screen_name, raw_data.twitter_id].join("-")
  end
end

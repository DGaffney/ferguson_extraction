class Tweet
  include MongoMapper::Document
  extend Aggregator
  key :ainternal_id, String
  key :_rev, String
  key :type, String
  key :doctrine_metadata
  key :lang
  key :content
  key :published
  key :title
  key :source
  key :authors
  key :categories
  key :links
  key :_attachments
  key :screen_name
  key :twitter_id
  key :user_id
  key :uuid
end
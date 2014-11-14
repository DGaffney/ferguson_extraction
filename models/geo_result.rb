class GeoResult
  include MongoMapper::Document
  extend Aggregator
  key :location
  key :content
end
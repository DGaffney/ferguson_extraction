class Edge
  include MongoMapper::Document
  key :uuid, String
  key :source, String
  key :target, String
  key :attributes, Array
end
class Edge
  include MongoMapper::Document
  key :uuid, String
  key :source, String
  key :target, String
  key :edge_attributes, Array
  key :type, String
end

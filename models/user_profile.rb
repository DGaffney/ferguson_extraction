class UserProfile
  include MongoMapper::Document
  key :user_id
  key :content
end
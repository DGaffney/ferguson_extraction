require 'geocoder'
class Geo
  include Sidekiq::Worker
  def self.queue_up
    UserProfile.fields("content.location").collect(&:content).collect(&:location).collect(&:downcase).collect(&:strip).uniq.each do |loc|
      Geo.perform_async(loc)
    end
  end

  def keys
    %w{
      AmkXmzXZF7hUdTWuFJ-nukOM8Z_lrlat_oDD86T3YM_bZuGNeLgTnvkIwoqJ66-6
      Ak1RKcO61wCCvvyf_iXiJo3Uy5NyPub8MdJK-JwVxnXgkeRzeHOo8kmMkO0EjQ_2
      AlvWkShIKn5XfUlr6gdEAJsVWsmLUX1JW4CRvMnb-LGfCuw39VW72M6awLeImeX9
    }
  end
  
  def config_geocoder
    Geocoder.configure(:lookup => :bing, :api_key => keys.shuffle.first)
  end
  
  def perform(location)
    config_geocoder
    loc = GeoResult.first_or_new(location: location)
    if loc.new?
      loc.content = Geocoder.search(location).first.data
      loc.save!
    end
  end
end
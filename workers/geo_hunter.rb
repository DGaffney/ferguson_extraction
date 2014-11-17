require 'geocoder'
class Geo
  include Sidekiq::Worker
  def self.queue_up
    offset = 0
    limit = 100
    set = UserProfile.fields("content.location").offset(offset).limit(limit).to_a
    while !set.empty?
      set.each do |loc|
        Geo.perform_async(loc.content.location.downcase.strip)
      end
      offset+=limit
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
      res = Geocoder.search(location).first.data rescue nil
      if res
        loc.content = res 
        loc.save!
      end
    end
  end
end
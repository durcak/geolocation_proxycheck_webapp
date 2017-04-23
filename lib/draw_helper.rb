require 'chunky_png'
require 'csv'

class DrawHelper

  def initialize
    @picture = ChunkyPNG::Image.from_file('./app/assets/images/viz_map.png')
		@point  = ChunkyPNG::Image.from_file('./lib/point5.png')
  end

  def add_point lat, lon
  	@picture.compose!(@point, count_x(lon.to_f), count_y(lat.to_f))
  end

  def save
		@picture.save('./app/assets/images/viz_map.png', :interlace => true)
  end

  private

  def count_x lon
	  pos = lon+170 
	  x = 6372*pos/227.509
	  return (x/10).to_i
	end

	def count_y lat
	  pos = lat+10.45 
	  x = 279*pos/(-8.99)+4911
	  return (x/10).to_i
	end
end
module MapsHelper

  # $BCO?^2hA|$rI=<($9$k(Bimg$B%?%0$N@8@.(B
  def map_image_tag(lat, lng, display)
    
    # $B2hLL%5%$%:$+$i!"CO?^2hA|%5%$%:$r5a$a$k(B
    if !display.nil? then
      map_width = display.width
      map_height = display.height / 2
    end

    if map_width.nil? || map_width < 240 then
      map_width = 240
    end
    if map_height.nil? || map_height < 240 then
      map_height = 240
    end

    # img$B%?%0$N@8@.(B
    src = "http://maps.googleapis.com/maps/api/staticmap?center=#{lat},#{lng}&zoom=15&size=#{map_width}x#{map_height}&sensor=false&format=jpg-baseline&markers=#{lat},#{lng}"
    return "<img src=\"#{src}\" alt=\"map\" width=\"#{map_width}\" height=\"#{map_height}\">"
  end

end

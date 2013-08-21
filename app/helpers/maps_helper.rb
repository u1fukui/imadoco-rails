module MapsHelper

  # 地図画像を表示するimgタグの生成
  def map_image_tag(lat, lng, display)
    
    # 画面サイズから、地図画像サイズを求める
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

    # imgタグの生成
    src = "http://maps.googleapis.com/maps/api/staticmap?center=#{lat},#{lng}&zoom=15&size=#{map_width}x#{map_height}&sensor=false&format=jpg-baseline&markers=#{lat},#{lng}"
    return "<img src=\"#{src}\" alt=\"map\" width=\"#{map_width}\" height=\"#{map_height}\">"
  end

end

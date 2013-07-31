# coding:utf-8
require 'houston'
require 'pp'

class MapsController < ApplicationController

  # ガラケー対応
  include Jpmobile::ViewSelector
  
  def show
    @key = params[:key]
    session[:map_key] = @key
  end

  # 指定された端末にpush通信を送る
  def push_notification(device_id, notification_id)
    logger.info "push notification!!!"

    notification = Houston::Notification.new(device: device_id)
    notification.alert = "相手からの反応がありました"
    
    # Notifications can also change the badge count, have a custom sound, indicate available Newsstand content, or pass along arbitrary data.
    notification.badge = 1
    notification.sound = "sosumi.aiff"
    notification.content_available = true
    notification.custom_data = {notification_id: notification_id}

    # And... sent! That's all it takes.
    Imadoco::Application.config.apn.push(notification)
  end

  # 位置情報の登録
  def register_notification
    lat = params[:lat]
    lng = params[:lng]
    key = params[:key]
    message = params[:message]

    # 位置情報が取得できない
    if lat.blank? || lng.blank? then
      render :template => "maps/error_gps"
      return
    end

    # パラメータチェック
    map = Map.find_by_public_id(key)
    if map.nil? then
      head 400
    end

    user = User.find(map.user_id)
    if user.nil? then
      head 400
    end

    # 通知生成
    notification = Notification.new
    notification.map_id = map.id
    notification.lat = lat
    notification.lng = lng
    notification.message = message
    notification.save!
    
    # 
    push_notification(user.device_id, notification.id)
  end

  # メッセージ入力画面を表示
  def register_position_mobile
    disable_mobile_view!   
    
    position = request.mobile.position
    if position.nil? then
      head 400
    end
    
    # フォームにセットされる
    @lat = request.mobile.position.lat
    @lng = request.mobile.position.lng
    @key = session[:map_key]

    # Cookie非対応
    if @key.blank? then
      render :template => "maps/error_cookie"
      return
    end

    # 位置情報が取得できない
    if @lat.blank? || @lng.blank? then
      render :template => "maps/error_gps"
      return
    end

    # 地図画像生成
    display = request.mobile.display
    if !request.mobile.display.nil? then
      map_width = display.width
      map_height = display.height / 2
    end

    if map_width.nil? || map_width < 240 then
      map_width = 240
    end
    if map_height.nil? || map_height < 240 then
      map_height = 240
    end

    src = "http://maps.googleapis.com/maps/api/staticmap?center=#{@lat},#{@lng}&zoom=15&size=#{map_width}x#{map_height}&sensor=false&mobile=true&markers=#{@lat},#{@lng}"
    @map_image_tag = "<img src=\"#{src}\" alt=\"map\" width=\"#{map_width}\" height=\"#{map_height}\">"
  end

end


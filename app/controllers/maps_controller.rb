# coding:utf-8
require 'houston'
require 'pp'

class MapsController < ApplicationController

  # 指定された端末にpush通信を送る
  def push_notification(device_id, notification_id)
    notification = Houston::Notification.new(device: device_id)
    notification.alert = "相手からの反応がありました"
    
    # Notifications can also change the badge count, have a custom sound, indicate available Newsstand content, or pass along arbitrary data.
    notification.badge = 1
    notification.sound = "sosumi.aiff"
    notification.content_available = true
    notification.custom_data = {notification_id: notification_id}

    apn = Imadoco2::Application.config.apn
    
    # And... sent! That's all it takes.
    Imadoco::Application.config.apn.push(notification)
  end


  # 位置情報の登録ページ
  def show
    logger.debug "debuggggg"
    logger.info "maps#show"
    logger.error "errorrr"
    @key = params[:key]
  end

  # 位置情報の登録
  def register_notification
    logger.info("register_notification")
    lat = params[:lat]
    lng = params[:lng]
    key = params[:key]
    message = params[:message]

    map = Map.find_by_public_id(key)
    user = User.find(map.user_id)

    notification = Notification.new
    notification.map_id = map.id
    notification.lat = lat
    notification.lng = lng
    notification.message = message

    notification.save!
    
    pp "push device_id = #{user.device_id}"
    push_notification(user.device_id, notification.id)
  end

end


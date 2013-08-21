# coding:utf-8
require 'houston'
require 'pp'

class MapsController < ApplicationController

  # これがないとdocomoでエラーになる
  skip_before_filter :verify_authenticity_token

  # ガラケー対応
  include Jpmobile::ViewSelector
  
  # 位置情報登録ページの表示
  def show
    @key = params[:key]

    map = Map.find_by_public_id(@key)
    if map.nil? then
     render :template => "errors/error_404", :status => 404, :content_type => 'text/html'
     return
    end

    session[:map_key] = @key
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
      render :template => "errors/error_500", :status => 500, :content_type => 'text/html'
      return
    end

    user = User.find(map.user_id)
    if user.nil? then
      render :template => "errors/error_500", :status => 500, :content_type => 'text/html'
      return
    end

    # 通知生成
    notification = Notification.create(map.id, lat, lng, message)
    
    # 通知
    push_notification(user.original_device_id(), notification.id)
  end

  # メッセージ入力画面を表示
  def register_position_mobile
    
    # Cookie非対応
    @key = session[:map_key]
    if @key.blank? then
      render :template => "maps/error_cookie"
      return
    end

    # 位置情報がない
    position = request.mobile.position
    if position.nil? then
      render :template => "maps/error_gps"
      return
    end
    
    # 位置情報が不正な値
    @lat = position.lat
    @lng = position.lng
    if @lat.blank? || @lng.blank? then
      render :template => "maps/error_gps"
      return
    end

    # 地図画像タグ生成
    @map_image_tag = self.class.helpers.map_image_tag(@lat, @lng, request.mobile.display)
  
  end

end


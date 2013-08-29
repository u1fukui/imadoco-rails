require 'houston'

# ブラウザから位置情報をサーバに登録する
class MapsController < ApplicationController

  # これがないとdocomoでエラーになる
  skip_before_filter :verify_authenticity_token

  # ガラケー対応
  include Jpmobile::ViewSelector


  # 位置情報登録ページの表示
  #
  # === パラメータ:
  # key::
  #   地図識別ID
  #
  # === 返り値:
  # Webページ
  #
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
  #
  # === パラメータ:
  # lat::
  #   登録する位置情報の緯度
  # lng::
  #   登録する位置情報の経度
  # key::
  #   地図識別ID
  # message (option)::
  #   登録するメッセージ
  #
  # === 返り値:
  # 成功したらThanksページ、失敗したらエラーページを返す
  #
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


  # 位置確認＆メッセージ入力ページを表示(ガラケー用)
  #
  # === パラメータ:
  # 位置情報::
  #   jpmobileを使用して抽象化されている
  # map_key (Cookie)::
  #   地図識別ID
  #
  # === 返り値:
  # Webページ
  #
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


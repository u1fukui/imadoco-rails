require 'openssl'

class V1::TasksController < ApplicationController
  skip_before_filter :verify_authenticity_token # allow CSRF
  
  # ユーザ登録
  def register_user

    user_id = params[:user_id].to_i
    user = User.find_by_id(user_id)

    # ユーザIDがない場合は新規作成。ある場合は、sessionIdの更新だけ
    if user.nil? then
      user = User.create(params[:device_type])
      if user.nil? then
        head 400
      end
    else
      if !user.update() then
        head 400
      end
    end

    logger.info("id = #{user.id}")
    logger.info("session = #{user.session}")

    render :json => {user_id: user.id, api_session: user.session}.to_json, :status => 202
  end

  # 端末の登録
  def register_device
    user_id = params[:user_id]
    api_session = params[:api_session]

 #   if User.is_invalid(user_id, api_session) then
 #     head 401
 #     return
 #   end

    user = User.find_by_id(user_id)
    user.update_device_id(params[:device_id])

    head 202
  end

  # 地図URLの生成
  def create_map
    user_id = params[:user_id]
    map_name = params[:map_name]

    # ユーザ確認
    api_session = params[:api_session]

    if User.is_invalid(user_id, api_session) then
      head 401
      return
    end

    map = Map.create(user_id, map_name)

    begin
      map.save!

      url = map.url()

      subject = "今どこ？"
      body = "ここから現在地を教えてー！\n#{url}\n\n---\n友人・家族の現在地をかんたん確認♪\nhttp://imado.co/"
      render :json => {mail_body: body, mail_subject: subject}.to_json, :status => 202

    rescue ActiveRecord::RecordNotUnique => e
      head 400
    end

  end

  # 居場所情報の取得
  def show_notifications
    user_id = params[:user_id]

    # ユーザ確認
    api_session = params[:api_session]
    p "session = #{api_session}"
    if User.is_invalid(user_id, api_session) then
      head 401
      return
    end


    notifications = Notification.leatest_notifications(user_id)
    #notifications = Map.joins(:notifications).select("notifications.id, maps.name, notifications.lat, notifications.lng, notifications.message, notifications.created_at").where(:user_id => user_id).order("notifications.id DESC")
    #positions = Position.joins(:map).select("positions.id, maps.public_id, positions.lat, positions.lng, positions.message, positions.created_at").where(:user_id => user_id)


    render :json => notifications.to_json(:root => false), :status => 200

  end

end

require 'openssl'

# アプリとのやりとりをするAPIクラス

class V1::TasksController < ApplicationController
  skip_before_filter :verify_authenticity_token # allow CSRF
  
  # ユーザ登録API
  # 
  # === パラメータ:
  # user_id (option)::
  #   APIを実行するユーザのID。
  #   ユーザIDがまた振り分けられていない場合は、パラメータを付けなくて良い。
  #
  # === 返り値:
  # user_id::
  #   APIを実行する時に必要なユーザID。
  # api_session::
  #   APIを実行する時に必要なセッションID。
  # 
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

    render :json => {user_id: user.id, api_session: user.session}.to_json, :status => 202
  end


  # Push通知の為のデバイスID登録API
  # 
  # === パラメータ:
  # user_id::
  #   API実行者のユーザID
  # api_session::
  #   セッションID
  #
  # === 返り値:
  # 成功時は、202
  #
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



  #
  # 地図URLの生成API
  #
  # === パラメータ:
  # user_id::
  #   API実行者のユーザID
  # map_name::
  #   識別する為の地図の名前(重複OK)
  # api_session::
  #   セッションID
  #
  # === 返り値:
  # mail_subject::
  #   メールタイトル
  # mail_body::
  #   メール本文
  #
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

  # 位置情報履歴の取得API
  #
  # === パラメータ:
  # user_id::
  #   API実行者のユーザID
  # api_session::
  #   セッションID
  #
  # === 返り値:
  # 位置情報オブジェクトの配列
  #
  def show_notifications
    user_id = params[:user_id]

    # ユーザ確認
    api_session = params[:api_session]
    p "session = #{api_session}"
    if User.is_invalid(user_id, api_session) then
      head 401
      return
    end

    # 通知履歴を取得
    notifications = Notification.leatest_notifications(user_id)

    render :json => notifications.to_json(:root => false), :status => 200

  end

end

require 'openssl'

class V1::TasksController < ApplicationController
  skip_before_filter :verify_authenticity_token # allow CSRF

  # 復号処理
  def decrypt(base64_text)

    s = base64_text.unpack('m')[0]

    dec = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
    dec.decrypt
    dec.key = Imadoco::Application.config.decrypt_key
    dec.iv = "\000"*32
    a = dec.update(s)
    b = dec.final

    return a + b
  end

  # 引数の数値を桁数にしたランダムな文字列を生成
  def create_random_string(num)
    return [*1..9, *'A'..'Z', *'a'..'z'].sample(num).join
  end

  # 無効なユーザかを判定
  def is_invalid_user(user_id, api_session)
    user = User.find_by_id_and_session(user_id, api_session)
    return user.nil?
  end

  # ユーザ登録
  def register_user

    # ユーザIDがない場合は新規作成。ある場合は、sessionIdの更新だけ
    user_id = params[:user_id].to_i
    user = User.find_by_id(user_id)

    if user.nil? then
      user = User.new
      user.device_type = params[:device_type]
    end
    user.session = create_random_string(20)
    user.save!

    render :json => {user_id: user.id, api_session: user.session}.to_json, :status => 202
  end

  # 端末の登録
  def register_device
    user_id = params[:user_id]
    api_session = params[:api_session]

    if is_invalid_user(user_id, api_session) then
      head 401
      return
    end

    device_id = decrypt(params[:device_id])
    user = User.find_by_id(user_id)
    user.update_attributes!(:device_id => device_id)

    head 202
  end

  # 地図URLの生成
  def create_map
    user_id = params[:user_id]
    map_name = params[:map_name]

    # ユーザ確認
    api_session = params[:api_session]

    if is_invalid_user(user_id, api_session) then
      head 401
      return
    end

    public_id = create_random_string(12)

    map = Map.new
    map.user_id = user_id
    map.name = map_name
    map.public_id = public_id

    begin
      map.save!

      url = "http://#{Imadoco::Application.config.content_host_name}/maps/#{public_id}"

      subject = "今どこ？"
      body = "ここから現在地を教えてー！\n#{url}\n\n---\n友人・家族の現在地をかんたん確認♪\nhttp://imado.co/"
      render :json => {mail_body: body, mail_subject: subject}.to_json, :status => 202

    rescue ActiveRecord::RecordNotUnique => e
      head 400
    end

  end

  # 地図の表示
  def show_map
    @key = params[:key]
    render :action => "maps"
  end

  # 居場所情報の取得
  def show_notifications
    user_id = params[:user_id]

    # ユーザ確認
    api_session = params[:api_session]
    p "session = #{api_session}"
    if is_invalid_user(user_id, api_session) then
      head 401
      return
    end

    notifications = Map.joins(:notifications).select("notifications.id, maps.name, notifications.lat, notifications.lng, notifications.message, notifications.created_at").where(:user_id => user_id).order("notifications.id DESC")
    #positions = Position.joins(:map).select("positions.id, maps.public_id, positions.lat, positions.lng, positions.message, positions.created_at").where(:user_id => user_id)


    render :json => notifications.to_json(:root => false), :status => 200

  end

end

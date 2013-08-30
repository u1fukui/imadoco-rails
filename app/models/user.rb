class User < ActiveRecord::Base

  has_many :maps

  # 無効なユーザかを判定
  #
  # === パラメータ:
  # user_id::
  #   ユーザ識別ID
  # api_session::
  #   セッションID
  #
  # === 返り値:
  # 無効なユーザの場合はtrue
  #
  def self.is_invalid(user_id, api_session)
    user = User.find_by_id_and_session(user_id, api_session)
    return user.nil?
  end


  # ユーザを作成してDBに登録
  #
  # === パラメータ:
  # device_type::
  #   端末の種類ID(0:iPhone, 1:Android)
  #
  # === 返り値:
  # ユーザの作成に成功したらuser。失敗したらnil。
  #
  def self.create(device_type)
    user = User.new
    user.device_type = device_type
    user.session = User.create_session()

    if user.save() then
      return user
    else
      return nil
    end
  end


  # セッションIDの更新
  #
  # === パラメータ:
  # なし
  #
  # === 返り値:
  # 成功したらtrue
  #
  def update
    return self.update_attributes(:session => User.create_session())
  end


  # デバイスIDの更新
  #
  # === パラメータ:
  # device_id
  #
  # === 返り値:
  # 成功したらtrue
  #
  def update_device_id(device_id)
    return self.update_attributes(:device_id => device_id)
  end

  # 復号したデバイスIDを取得
  #
  # === パラメータ:
  # なし
  #
  # === 返り値:
  # 成功したらtrue
  #
  def original_device_id
    return User.decrypt(self.device_id)
  end

  private

  # 復号処理
  def self.decrypt(base64_text)

    s = base64_text.unpack('m')[0]

    dec = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
    dec.decrypt
    dec.key = Imadoco::Application.config.decrypt_key
    dec.iv = "\000"*32
    a = dec.update(s)
    b = dec.final

    return a + b
  end

  def self.create_session
    return [*1..9, *'A'..'Z', *'a'..'z'].sample(20).join
  end

end


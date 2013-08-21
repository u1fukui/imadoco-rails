class User < ActiveRecord::Base
  has_many :maps

  # 無効なユーザかを判定
  def self.is_invalid(user_id, api_session)
    user = User.find_by_id_and_session(user_id, api_session)
    return user.nil?
  end

  # 新規ユーザの作成
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

  # 更新
  def update
    return self.update_attributes(:session => User.create_session())
  end

  # デバイスIDの更新
  def update_device_id(device_id)
    return self.update_attributes(:device_id => device_id)
  end

  # 複合したデバイスIDを取得
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

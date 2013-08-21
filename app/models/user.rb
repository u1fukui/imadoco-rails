class User < ActiveRecord::Base
  has_many :maps

  # $BL58z$J%f!<%6$+$rH=Dj(B
  def self.is_invalid(user_id, api_session)
    user = User.find_by_id_and_session(user_id, api_session)
    return user.nil?
  end

  # $B?75,%f!<%6$N:n@.(B
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

  # $B99?7(B
  def update
    return self.update_attributes(:session => User.create_session())
  end

  # $B%G%P%$%9(BID$B$N99?7(B
  def update_device_id(device_id)
    return self.update_attributes(:device_id => device_id)
  end

  # $BJ#9g$7$?%G%P%$%9(BID$B$r<hF@(B
  def original_device_id
    return User.decrypt(self.device_id)
  end

  private

  # $BI|9f=hM}(B
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

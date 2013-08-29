class Map < ActiveRecord::Base
  belongs_to :user
  has_many :notifications

  # Mapを生成してDBに登録する
  #
  # === パラメータ:
  # user_id::
  #   Map所有者のID
  # name::
  #   Mapの名前
  #
  # === 返り値:
  # 保存に成功したら生成したMap。失敗したらnil。
  #
  def self.create(user_id, name)
    map = Map.new
    map.user_id = user_id
    map.name = name
    map.public_id = Map.create_map_key()

    if map.save() then
      return map
    else
      return nil
    end
  end

  # URL取得
  # 指定した端末にpush通信を送る
  #
  # === パラメータ:
  # device_id::
  #   Push通知を送るデバイスID
  # notification_id::
  #   通知識別ID
  #
  # === 返り値:
  # なし
  #
  def url()
    return "http://#{Imadoco::Application.config.content_host_name}/maps/#{self.public_id}"
  end


  private

  def self.create_map_key
    return [*1..9, *'A'..'Z', *'a'..'z'].sample(12).join
  end
end

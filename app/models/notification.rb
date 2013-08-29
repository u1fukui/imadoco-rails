class Notification < ActiveRecord::Base
  belongs_to :map
  belongs_to :user

  # 通知オブジェクトの生成
  #
  # === パラメータ:
  # map_id::
  #   地図ID
  # lat::
  #   位置情報の緯度
  # lng::
  #   位置情報の経度
  # message::
  #   メッセージ
  #
  # === 返り値:
  # 成功したらnotificationインスタンスを返す
  #
  def self.create(map_id, lat, lng, message)
    notification = Notification.new
    notification.map_id = map_id
    notification.lat = lat
    notification.lng = lng
    notification.message = message

    if notification.save() then
      return notification
    else
      return nil
    end
  end

  # セッションIDの更新
  #
  # === パラメータ:
  # user_id::
  #   ユーザID
  #
  # === 返り値:
  # 指定したユーザのnotification配列(新しい順)。存在しない場合はnil。
  #
  def self.leatest_notifications(user_id)
     return Map.joins(:notifications).select("notifications.id, maps.name, notifications.lat, notifications.lng, notifications.message, notifications.created_at").where(:user_id => user_id).order("notifications.id DESC")
  end

end

class Notification < ActiveRecord::Base
  belongs_to :map
  belongs_to :user


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

  def self.leatest_notifications(user_id)
     return Map.joins(:notifications).select("notifications.id, maps.name, notifications.lat, notifications.lng, notifications.message, notifications.created_at").where(:user_id => user_id).order("notifications.id DESC")
  end

end

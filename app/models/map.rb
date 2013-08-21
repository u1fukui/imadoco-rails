class Map < ActiveRecord::Base
  belongs_to :user
  has_many :notifications

  # $B@8@.(B
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

  # URL$B<hF@(B
  def url()
    return "http://#{Imadoco::Application.config.content_host_name}/maps/#{self.public_id}"
  end


  private

  def self.create_map_key
    return [*1..9, *'A'..'Z', *'a'..'z'].sample(12).join
  end 

end

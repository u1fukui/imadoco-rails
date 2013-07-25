class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :device_type
      t.string :device_id
      t.string :session
      
      t.timestamps
    end
  end
end

class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :map_id
      t.float :lat
      t.float :lng
      t.string :message

      t.timestamps
    end
  end
end

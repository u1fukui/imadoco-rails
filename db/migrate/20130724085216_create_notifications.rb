class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :map_id, :null => false
      t.float :lat
      t.float :lng
      t.string :message
      t.column :pushed, :boolean, :null => false, :default => false

      t.timestamps
    end

    add_index :notifications, :map_id

  end
end

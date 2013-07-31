class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :device_type, :null => false
      t.string :device_id
      t.string :session
      
      t.timestamps
    end
    
    add_index :users, [:id, :session], :unique => true
  end
end

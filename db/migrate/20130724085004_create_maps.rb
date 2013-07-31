class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.integer :user_id, :null => false
      t.string :public_id, :null => false
      t.string :name

      t.timestamps
    end

    add_index :maps, :user_id

  end
end

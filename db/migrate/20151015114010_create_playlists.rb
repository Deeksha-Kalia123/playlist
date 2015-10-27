class CreatePlaylists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.string :name
      t.string :type
      t.integer :user_id
      t.timestamps null: false
    end
  end
end

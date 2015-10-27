class AddSongToPlaylists < ActiveRecord::Migration
  def change
      create_table "songs", force: :cascade do |t|
      t.attachment :song
      t.integer  "playlist_id"
      t.integer  "user_id"
      t.datetime "created_at",        null: false
      t.datetime "updated_at",        null: false
    end
  end
end

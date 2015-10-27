class AddPhotoToPlaylists < ActiveRecord::Migration
  def change
     create_table "photos", force: :cascade do |t|
      t.attachment :photo
      t.integer  "playlist_id"
      t.integer  "user_id"
      t.datetime "created_at",                         null: false
      t.datetime "updated_at",                         null: false
      t.integer  "price",              default: 0
      t.string   "unit",               default: "usd"
   end
  end
end

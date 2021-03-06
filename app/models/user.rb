class User < ActiveRecord::Base
  has_many :playlists, dependent: :destroy
  has_many :songs, through: :playlists
  has_many :photos, through: :playlists
  before_action :authenticate_user!
end

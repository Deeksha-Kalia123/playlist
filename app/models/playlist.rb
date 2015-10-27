class Playlist < ActiveRecord::Base
  has_many :songs
  has_many :photos
  belongs_to :user
  self.inheritance_column = :_type_disabled
  #self.inheritance_column = :nil 
end

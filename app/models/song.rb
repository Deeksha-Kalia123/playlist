class Song < ActiveRecord::Base
  belongs_to :playlist
  belongs_to :user
  has_attached_file :song, default_url: "/songs/:style/missing.mp3"
   
   #validates_attachment :song, content_type: { content_type: ['application/mp3','application/force-download','application/x-mp3',"application/ogg","image/jpg", "image/jpeg", "image/png", "image/gif", "application/pdf","audio/mpeg","audio/mpeg","application/octet-stream",/\Aaudio/,/\Avideo/] }
    validates_attachment_content_type :song, :content_type => [ 'audio/mp3','audio/mpeg']
end

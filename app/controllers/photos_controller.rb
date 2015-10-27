class PhotosController < ApplicationController
   before_action :set_playlist, only: [:new,:create]
  def index
    @photos = Photo.where(playlist_id: params[:playlist_id])
  end
  
  def new
    @photo = Photo.new
  end
  
  def create
    @photo = @playlist.photos.create(photos_params)
    if @photo.save
      flash[:success] = "The photo was added!"
      redirect_to playlists_path
    end
  end
  private
  def photos_params
    params.require(:photo).permit(:photo)
  end
  
  def set_playlist
    @playlist= Playlist.find(params[:playlist_id])
  end     
end

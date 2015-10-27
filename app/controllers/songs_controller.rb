class SongsController < ApplicationController
  before_action :set_playlist, only: [:new,:create]
  def index
    @songs = Song.all
  end

  def new
    @song= Song.new
  end
  
  def create
    @song = @playlist.songs.create(song_params)
    debugger
    if @song.save
      flash[:success] = "Song is Added!"
      redirect_to playlists_path
    else
      render :new
    end
  end
  private
  def song_params
    params.require(:song).permit(:song)
  end
  
  def set_playlist
    @playlist = Playlist.find(params[:playlist_id])
  end
end

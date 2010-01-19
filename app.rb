require 'rubygems'
require 'sinatra'
require 'hpricot'
require 'open-uri'
require 'meta-spotify'
require 'haml'

def calendar_url(username)
  "http://www.songkick.com/users/#{username}/calendar"
end

def get_upcoming_artists(username)
  doc = Hpricot(open(calendar_url(username)))
  doc.search("//span.headliners").collect {|h| h.inner_html }
end

def spotify_artist_link(artist)
  begin
    spotify_uri = MetaSpotify::Artist.search(artist)[:artists].first.uri
    "<a href='#{spotify_uri}'>#{artist}</a>"
  rescue
    "<span class='not_found'>#{artist}</span> <span class='not_found_message'>(not found on Spotify)</span>"
  end
end

get '/' do
  @username = params[:username]
  unless @username.nil?
    begin 
      @upcoming_artists = get_upcoming_artists(@username)
    rescue
      @message = "Songkick user not found: #{@username}"
      @upcoming_artists = []
    end
  end
  haml :index
end

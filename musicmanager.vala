public class Tempo.MusicManager {

    private string music_dir;
        
    public List<MediaObject> song_files;
    public List<AlbumObject> album_objects;
    
    private LastFm lastfm;
    
    private File art_dir;
    private string art_dir_uri;
        
    public MusicManager () {
        this.music_dir = Tracker.Sparql.escape_string
                            (Gst.filename_to_uri
                            (Environment.get_user_special_dir
                            (UserDirectory.MUSIC)));
         
        song_files = new List<MediaObject> ();
        album_objects = new List<AlbumObject> ();
        
        this.load_music ();
        this.load_albums();
        
        var cache_dir = Environment.get_user_cache_dir ();      
        art_dir_uri = cache_dir + "/tempo/media-art/";  
        DirUtils.create_with_parents (art_dir_uri, 0775);
        
        lastfm = new LastFm();
            
        for (int i = 0; i < album_objects.length(); i++) {
            var art_file = File.new_for_uri (art_dir_uri + 
                                             lastfm.generate_image_key(
                                                album_objects.nth_data(i).title
                                             ));
            
            set_album_art(album_objects.nth_data(i));
        }
    
    }
    
    public string[] query_songs () {
    
        string[] song_list = {" "};
    
        var query =
            "SELECT 
                nie:url(?song)
                nie:title(?song)
            WHERE {
                ?song a nmm:MusicPiece
                FILTER (
                    tracker:uri-is-descendant(
                        '" + music_dir + "', nie:url(?song)
                    )
                )
            }
        ";
        

        query.replace ("\n", " ");
        query.strip();
        
        Tracker.Sparql.Connection connection;
        
        connection = Tracker.Sparql.Connection.get();
        var cursor = connection.query(query);
        
        int i = 0;
        
        while (cursor.next()) {
            i = i + 1;                        
            song_list += cursor.get_string(0);
        }
        return song_list;
    }
    
    public void load_music () {

        string[] song_list = this.query_songs();
        
        for (int i = 0; i < song_list.length; i++) {
            
            song_list[i].replace("%20", " ");
            
            var song = new MediaObject(song_list[i]);
                        
            song_files.append(song);
        }
    }
    
    public bool find_from_uri (string uri, out MediaObject obj) {
        
        for (int i = 0; i < song_files.length(); i++) { 
            if (song_files.nth_data (i).media_uri == uri) {
                obj = song_files.nth_data (i);
                return true;
            }
        }
        
        return false;
    }
    
    public void load_albums () {
        
        var cursor = this.query_albums ();
        
        int i = 0;
        
        while (cursor.next ()) {
            i = i + 1;
            
            var artist_str = cursor.get_string(4).replace("urn:artist:", "");
            artist_str = artist_str.replace ("%20", " ");
            
            var temp_album = new AlbumObject ();
            
            temp_album.title = cursor.get_string(1);
            temp_album.song_count = cursor.get_string(2);
            temp_album.artist = artist_str;
                       
            for (int x = 0; x < this.song_files.length(); x++) {
            
                if (this.song_files.nth_data(x).album == temp_album.title) {
                
                    temp_album.add_song_to_album (this.song_files.nth_data(x));
                }
            }
                        
            this.album_objects.append (temp_album);
        }
    }
    
    public Tracker.Sparql.Cursor query_albums () {
        var query =
            "SELECT 
                ?album
                ?title
                COUNT(?song) AS songs
                SUM(?length) AS totallength
                ?performer
            WHERE {
                ?album a nmm:MusicAlbum ;
                         nie:title ?title .
                ?song nmm:musicAlbum ?album ;
                      nfo:duration ?length ;
                      nmm:performer ?performer
                FILTER (
                    tracker:uri-is-descendant(
                        '" + music_dir + "', nie:url(?song)
                    )
                )
            }
            GROUP BY ?album
        ";
        
        query.replace ("\n", " ");
        query.strip();
        
        Tracker.Sparql.Connection connection;
        
        connection = Tracker.Sparql.Connection.get();
        var cursor = connection.query (query);
    
        return cursor;
    }
    
    public MediaObject? get_current_media (StreamPlayer player) {
    
        MediaObject? current = null;
    
        find_from_uri (player.get_current_media_file(), out current);
        
        return current;
    }
    
    //Use this async function in for loop, if the art for an image cannot be found in the cache directory
    
    public async void set_album_art (AlbumObject album) { 
        SourceFunc resume = set_album_art.callback;
        
        string query_album = album.title.replace (" ", "+");
        string query_artist = album.artist.replace (" ", "+");
        
        string? uri = null;
        Gdk.Pixbuf? pix = null;
        
        new Thread<void*> (null, () => {        
            uri = lastfm.get_art_uri (query_album, query_artist);
            lastfm.download_cover_art (uri, art_dir_uri);
                                            
            string art_src = art_dir_uri + lastfm.generate_image_key(uri);                 
                                
            pix = new Gdk.Pixbuf.from_file_at_scale (art_src, 128, 128, true);    
            var art = album.make_frame (pix);
            album.album_art.set_from_pixbuf (art);                
                                
            Idle.add ((owned) resume);
            return null;
        });
                        
        yield;
    }
}

class Tempo.MusicManager {

    private string music_dir;
    
    public MediaObject[] song_files;
    public AlbumObject[] album_objects;
    
    private LastFm lastfm;
    
    private File art_dir;
    
    public MusicManager () {
        this.music_dir = Tracker.Sparql.escape_string
                            (Gst.filename_to_uri
                            (Environment.get_user_special_dir
                            (UserDirectory.MUSIC)));
         
        song_files = { };
        album_objects = { };
        
        this.load_music ();
        this.load_albums();
        
        lastfm = new LastFm();
        
        art_dir = File.new_for_uri (Environment.get_user_cache_dir() + "/tempo");
        if (art_dir == null) {
            art_dir.make_directory ();
        }
        
  
        set_album_art.begin ((obj, result) => {
            set_album_art.end (result);
        });
  
        /*Thread<void*> album_art_thread = new Thread<void*> 
                                             ("album_art_thread", 
                                              set_album_art);
        album_art_thread.yield(); <--- and attempt that failed */
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
                        
            song_files += song;
        }
    }
    
    public bool find_from_uri (string uri, out MediaObject obj) {
        
        for (int i = 0; i < song_files.length; i++) { 
            if (song_files[i].media_uri == uri) {
                obj = song_files[i];
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
                       
            for (int x = 0; x < this.song_files.length; x++) {
            
                if (this.song_files[x].get_tag_album () == temp_album.title) {
                
                    temp_album.add_song_to_album (this.song_files[x]);
                }
            }
                        
            this.album_objects += temp_album;
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
    
    /*private async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
        GLib.Timeout.add (interval, () => {
            nap.callback();
            return false;
        }, priority);
        yield;
    }*/
    
    private async void set_album_art () {
        
        SourceFunc callback = set_album_art.callback;        
              
        ThreadFunc<void*> run = () => { 
        Idle.add((owned) callback);
        for (int i = 0; i < album_objects.length; i++) {
            string album = album_objects[i].title;
            album = album.replace (" ", "+");
            
            string artist = album_objects[i].artist;
            artist = artist.replace (" ", "+");
        
            string url = lastfm.get_art_uri (artist, album);
            
            stdout.printf ("\nGETTING ART FOR: %s\n", album_objects[i].title);
            
            //album_object[i].album_art_location = url; //For future reference?
            
            Gdk.Pixbuf pixbuf = lastfm.download_cover_art (url);
            album_objects[i].album_art.set_from_pixbuf (pixbuf);
            string file_uri = "";
            //save_art_to_dir (pixbuf, url, out file_uri);
            //stdout.printf ("\nURI IS: %s\n", file_uri);
                
            //File file = File.new_for_uri (file_uri);
                                    
            //album_objects[i].load_album_art(file);
            //Thread.usleep (1000);
            //Thread.yield ();
            }
        
        return null;
        };
        Thread.create<void*> (run, false);  
        
        yield;
    }
    
    /*
    
    FIXME: Function designed to save art to a directory for future use, broken 
    
    private void save_art_to_dir (Gdk.Pixbuf pixbuf, string url, out string file_uri) {
    
        string name = lastfm.generate_image_key (url);
        //File file = File.new_for_uri ("file:///home/xylon/" + name);//art_dir.get_uri() + "/" + name);
        //IOStream ios = file.create_readwrite (FileCreateFlags.PRIVATE);
        
        //OutputStream outstream = file.create (FileCreateFlags.NONE);
        
        //pixbuf.save_to_stream (outstream, "png");
        
        pixbuf.save ("file:///home/user/.cache/tempo/" + name, "png");
        
        //stdout.printf ("\nURI IS: %s\n\n\n\n\n", file.get_uri()); <--- DEBUGGING
        
        //outstream.close();
        
        //file_uri = file.get_uri();        
    }*/
}

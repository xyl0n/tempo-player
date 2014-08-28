public class Tempo.AlbumObject {
    
    public string title;
    public string song_count;
    public string artist;
    
    public Gtk.Image album_art;
    
    private MediaObject[] song_list;
    
    public AlbumObject() {
    
        album_art = new Gtk.Image.from_icon_name 
                            ("view-media-playlist",
                             Gtk.IconSize.LARGE_TOOLBAR);
    
        song_list = { };
    }
    
    public void add_song_to_album (MediaObject song) {
        this.song_list += song;
    }
    
    public MediaObject? get_song_at_number (int num) {
        num++;
        for (int i = 0; i < song_list.length; i++) {
            if (song_list[i].track_num == num) {
                stdout.printf ("SONG: %s at NUMBER: %d\n", song_list[i].title, (int)song_list[i].track_num);
                return song_list[i];
            }
        }
        
        return null;
    } 
    
    public int get_song_count () {
        return song_list.length;
    }
    
    public void load_album_art (File art_image) {
        album_art.set_from_file (art_image.get_uri());
    }
    
}

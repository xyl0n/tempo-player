public class Tempo.MediaObject {
    
    public string media_uri;
    
    private Gee.HashMap<string, string> tags;

    public string title;
    public string artist;
    public string genre;
    public string album;

    private File song_file;
    
    public MediaObject (string location) {
        
        this.media_uri = location;
        
        song_file = File.new_for_uri (media_uri);
        
        if (!song_file.query_exists ()) {
            stderr.printf ("File %s does not exist.\n", song_file.get_path());
        }
        
        this.discover_tags ();
    }

    private void discover_tags () {
        
        Gst.PbUtils.Discoverer discoverer = null;
        
        try {
            discoverer = new Gst.PbUtils.Discoverer (5 * Gst.SECOND);
        } catch (Error e) {
            stderr.printf ("Discoverer Error %d: %s\n", e.code, e.message);
        }

        Gst.PbUtils.DiscovererInfo info = null;
        
        try {
            info = discoverer.discover_uri (this.media_uri);
        } catch (Error e) {
            stderr.printf ("Discoverer Error %d: %s\n", e.code, e.message);
        }
        
        var file_tags = info.get_tags();    
        string tag_val;
        
        file_tags.get_string ("title", out tag_val);
        this.title = tag_val;
               
        file_tags.get_string ("artist", out tag_val);
        this.artist = tag_val;
        
        file_tags.get_string ("genre", out tag_val);
        this.genre = tag_val;
        
        file_tags.get_string ("album", out tag_val);
        this.album = tag_val;
    }
    
    public string get_tag_title () {
        return this.title;
    }

    public string get_tag_artist () {
        return this.artist;
    }
    
    public string get_tag_genre () {
        return this.genre;
    }
    
    public string get_tag_album () {
        return this.album;
    }
}


//--------------------------------------------------------------------------

public class LastFm {
    
    private const string API = "9033581d776b19c4ff002081ff58f349";
    
    public void download_cover_art (string url) {
        
        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", url);
        
        session.send_message (message);
        
        Gdk.PixbufLoader loader = new Gdk.PixbufLoader ();
        loader.write (message.response_body.data); 
        
        Gdk.Pixbuf image = loader.get_pixbuf ();
        string name = generate_image_key (url);
        
        image.save (name, "png"); //currently it just saves the album art in the source folder
                                  // TODO: Make it save and load from a cache folder
        
        loader.close ();

    }    
    
    public string generate_image_key (string text) {
        return GLib.Checksum.compute_for_string(ChecksumType.MD5, text, text.length);
    }    
    
    public string get_art_uri (string query_artist, string query_album) { 
        
        var url = "http://ws.audioscrobbler.com/2.0/?api_key="+ API + 
                   "&method=album.getinfo&artist=" + 
                   query_artist + "&album=" + query_album + "&format=json";
        
        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", url);
        
        var headers = new Soup.MessageHeaders (Soup.MessageHeadersType.REQUEST);
        headers.append("api_key", API);
        headers.append("method", "album.getInfo");
        headers.append("artist", query_artist);
        //headers.append("sk", auth_token); <--- Don't need this
        headers.append("album", query_album);
        
        session.timeout = 30;
        
        session.send_message (message);
        
        //stdout.write(message.response_body.data); <--- FOR DEBUGGING PURPOSES
                
        Json.Parser parser = new Json.Parser ();
        
        parser.load_from_data ((string)message.response_body.data);
        Json.Node root = parser.get_root ();        
                
        return parse_node (root, " ");
    }
    
    private string parse_node (Json.Node node, string parent) {
    
        unowned Json.Object obj = node.get_object ();
    
        string str = null;
    
        foreach (unowned string name in obj.get_members()) {
            switch (name) {
            case "album":
                stdout.printf ("\nALBUM FOUND\n");
                
                var child = obj.get_member (name);
                var child_obj = child.get_object ();
                
                foreach (unowned string child_name in child_obj.get_members()) {
                    switch (child_name) {
                    case "image":
                        var image_array = child_obj.get_member (child_name).get_array();
                        
                        int i = 1;
                        
                        foreach (unowned Json.Node child_node in image_array.get_elements()) {
                            str = parse_array (child_node, i, image_array);
                            i++;
                        }
                    break;
                    }
                }                
            break;
            }
        }
        
        return str;
    }
    
    private string parse_array (Json.Node node, uint number, Json.Array parent_array) {
        
        unowned Json.Object obj = node.get_object ();
                
        string str = null;        
                
        foreach (unowned string name in obj.get_members()) {
            switch (name) {
                case "size":
                    unowned Json.Node item = obj.get_member (name);
                    
                    if (item.get_string() == "mega") {
                        str = get_image_url (item, number, parent_array);     
                    }
                                        
                    break;
            }
        }
        
        return str;    
    }
    
    private string get_image_url (Json.Node node, uint number, Json.Array parent_array) {
        
        unowned Json.Object child = parent_array.get_object_element (number - 1);
        
        string url = null;
        
        foreach (unowned string name in child.get_members()) {
            switch (name) {
                case "#text":
                    unowned Json.Node item = child.get_member (name);
                                        
                    url = child.get_string_member ("#text");
                                        
                    break;
            }
        }
        
        return url;
    }
}

//An Album Object class
public class AlbumObject {
    
    public string title;
    public string song_count;
    public string artist;
    
    public Gtk.Image album_art;
    public Gdk.Pixbuf album_pix;
        
    public AlbumObject() {
    
        Gtk.IconTheme theme = Gtk.IconTheme.get_default ();
        Gtk.IconInfo info = theme.lookup_icon ("folder-music-symbolic", 96,
                                               Gtk.IconLookupFlags.FORCE_SVG); //Default icon
        
        album_pix = info.load_icon ();
    
        album_art = new Gtk.Image.from_pixbuf (album_pix);
    }     
}

public async void set_album_art (AlbumObject album, LastFm lastfm) { 
    SourceFunc resume = set_album_art.callback;
        
    string query_album = album.title.replace (" ", "+");
    string query_artist = album.artist.replace (" ", "+");
        
    string? uri = null;
    Gdk.Pixbuf? pix = null;
        
    new Thread<void*> (null, () => {
        stdout.printf ("Thread started\n");        
        uri = lastfm.get_art_uri (query_artist, query_album);
        lastfm.download_cover_art (uri);
                                
        pix = new Gdk.Pixbuf.from_file_at_scale (lastfm.generate_image_key(uri),
                                                 96, 96, true);    
        album.album_art.set_from_pixbuf (pix);                
                                
        Idle.add ((owned) resume);
        return null;
    });
                        
    yield;
} 
    
int main (string args[]) {

    Gtk.init (ref args);
    LastFm lastfm = new LastFm();
    
    var window = new Gtk.Window ();
    window.show ();
        
    List<AlbumObject> album_objects = new List<AlbumObject>();
    
    string[] random_albums = {"Magic", "Mylo Xyloto", "Parachutes", "American Idiot", "The Black Parade", "Hybrid Theory"};
    string[] random_artists = {"Coldplay", "Coldplay", "Coldplay", "Green Day", "My Chemical Romance", "Linkin Park"};
    
    for (int n = 0; n < random_albums.length; n++) {
        var temp_album = new AlbumObject();
        temp_album.title = random_albums[n];
        temp_album.artist = random_artists[n];
        album_objects.append (temp_album);
    }
    
    Gtk.main ();
    
    return 0;
}

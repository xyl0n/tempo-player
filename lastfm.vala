public class LastFm {
    
    private const string API = "25341653e7638609a59a8c0b121f67f9";
    private const string SECRET = "8ab1bdd702c5f6f6733f97fd937e916e";
        
    private string auth_token = " ";
    
    public LastFm () {
    
        //this.generate_auth_token (); <---- Don't need authorisation for album art
    }
    
    /*private async void generate_auth_token () {
    
        SourceFunc callback = generate_auth_token.callback;
    
        string url = "http://ws.audioscrobbler.com/2.0/?method=auth.gettoken&api_key=" 
                     + this.API + "&format=json";
        
        var session = new Soup.Session ();
        var message = new Soup.Message ("POST", url);
        
        var headers = new Soup.MessageHeaders (Soup.MessageHeadersType.REQUEST);
        headers.append("api_key", this.API);
        headers.append("method", "auth.getToken");
        
        message.request_headers = headers;
        
        session.send_message (message);
        
        //stdout.write (message.response_body.data);
        
        Json.Parser parser = new Json.Parser ();
        
        parser.load_from_data ((string)message.response_body.data);
        Json.Node root = parser.get_root ();   
        
        unowned Json.Object obj = root.get_object ();
        
        foreach (unowned string name in obj.get_members()) {
            switch (name) {
            case "token":
                stdout.printf ("\nTOKEN FOUND\n");
                
                Json.Node item = obj.get_member (name);
                this.auth_token = item.get_string ();
            break;
            }
        }
        
        Idle.add ((owned) callback);
    }*/
    
    public Gdk.Pixbuf? download_cover_art (string url) {
        
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
        
        return new Gdk.Pixbuf.from_file_at_scale (name, 128, 128, true);
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

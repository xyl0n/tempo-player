public class LastFm {
    
    private const string API = "removed because reasons";
    
    public string? image_uri = null;
    
    public Gdk.Pixbuf? download_cover_art (string url) {//string url, string dest) {
        
        var session = new Soup.Session ();
        var message = new Soup.Message ("GET", url);
        
        session.send_message (message);
        
        Gdk.PixbufLoader loader = new Gdk.PixbufLoader ();
        loader.write (message.response_body.data); 
        
        Gdk.Pixbuf image = loader.get_pixbuf ();
        string name = generate_image_key (url);
        
        //image.save (dest + name, "png");        
        loader.close ();
        
        return image;
    }    
    
    public string generate_image_key (string text) {
        return GLib.Checksum.compute_for_string(ChecksumType.MD5, text, text.length);
    }    
        
    public string? get_art_uri (string query_album, string query_artist) {
        var url = "http://ws.audioscrobbler.com/2.0/?api_key="+ API + 
                  "&method=album.getinfo&artist=" + query_artist + "&album=" + query_album;
        
        Xml.Doc* doc = Xml.Parser.parse_file (url);
        doc->save_file ("test2");
        if (doc == null) {
            stderr.printf ("LastFM Album info not found\n");
            return null;
        }
        
        Xml.Node* root = doc->get_root_element ();
        if (root == null) {
            delete doc;
            stderr.printf ("Could not find any elements for album %s\n", query_album);
            return null;
        }

        parse_node (root, "");     
        
        delete doc;   
        
        return this.image_uri;     
    }
    
    
    // Sorry for stealing your code elementary :P
    
    private void parse_node (Xml.Node* node, string parent) {
    
        // Loop over the passed node's children
        for (Xml.Node* iter = node->children; iter != null; iter = iter->next) {
        
            // Spaces between tags are also nodes, discard them
            if (iter->type != Xml.ElementType.ELEMENT_NODE) {
                continue;
            }

            string node_name = iter->name;
            string node_content = iter->get_content ();
                       
            if(parent == "album") {
                if(node_name == "image") {
                    if(iter->get_prop("size") == "large") {
                        image_uri = node_content;
                    }
                }
            }

            // Followed by its children nodes
            parse_node (iter, parent + node_name);
        }
    }
}

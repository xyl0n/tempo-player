public class Tempo.AlbumSidebar : Gtk.Grid {

    private AlbumObject current_album;
    
    public signal void has_children ();
    public signal void album_to_queue (AlbumObject album);
    public signal void album_shuffle (AlbumObject album);
        
    public AlbumSidebar () {
        this.get_style_context().add_class (Gtk.STYLE_CLASS_SIDEBAR);
        
        this.set_size_request (300, -1);
        
        current_album = new AlbumObject ();
    }
    
    public void set_current_album (AlbumObject album) {
        this.current_album = album;
        this.clear_widgets ();       
        this.setup_layout ();
        
        has_children ();
    }
    
    public signal void song_clicked (MediaObject song);
    
    private void setup_layout () {
    
        Gtk.Image img = new Gtk.Image();
        
        //use Gtk.ImageType later
        
        string icon_name;
        Gtk.IconSize icon_size;
        current_album.album_art.get_icon_name (out icon_name, out icon_size);
        
        if (current_album.album_art.get_pixbuf() != null) {    
            img.set_from_pixbuf (current_album.album_art.get_pixbuf());
        } else {
            img.set_from_icon_name ("folder-music-symbolic", icon_size); // get image directly from album object in future
        }
        
        if (img != null) {
    
            var box = new Gtk.EventBox (); //??
    
            img.set_pixel_size (128);
            img.xalign = 0.5f;
            img.yalign = 0.0f;
            img.margin_top = 12;
            img.margin_bottom = 12;
            
            box.add (img); //??
            
            box.set_hexpand(true);
                               
            this.attach (box, 0, 0, 1, 1);
        }
        
        var album_name = new Gtk.Label (current_album.title);
        
        var attributes = new Pango.AttrList ();
        var scale = Pango.attr_scale_new (1.5);
        
        attributes.insert (scale.copy());
              
        album_name.set_attributes (attributes);
        
        album_name.set_line_wrap(true);
        album_name.set_size_request (300, -1);
        album_name.set_justify (Gtk.Justification.CENTER);
        
        album_name.size_allocate.connect ((allocation) => {    
                album_name.set_size_request (allocation.width - 50, -1);
        });
        
        this.attach (album_name, 0, 1, 1, 1);
        
        /*----*/
        
        var artist_name = new Gtk.Label (current_album.artist);
        
        var artist_attr = new Pango.AttrList ();
        var artist_scale = Pango.attr_scale_new (1.1);
        
        artist_attr.insert (artist_scale.copy());
              
        album_name.set_attributes (artist_attr);
        
        artist_name.set_line_wrap(true);
        artist_name.set_size_request (300, -1);
        artist_name.set_justify (Gtk.Justification.CENTER);
        
        artist_name.size_allocate.connect ((allocation) => {    
                artist_name.set_size_request (allocation.width - 50, -1);
        });
        
        this.attach (artist_name, 0, 2, 1, 1);
        
        var album_add_btn = new Gtk.Button.from_icon_name 
                                    ("list-add-symbolic", Gtk.IconSize.BUTTON);
        album_add_btn.clicked.connect (() => {
            album_to_queue (current_album);
        });
       
        var album_shuffle_btn = new Gtk.Button.from_icon_name 
                                    ("media-playlist-shuffle-symbolic", Gtk.IconSize.BUTTON);
        album_shuffle_btn.clicked.connect (() => {
            album_shuffle (current_album);
        });
       
        var album_options_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        album_options_box.pack_start (album_add_btn, false);
        album_options_box.pack_start (album_shuffle_btn, false);
        album_options_box.margin = 6;
        album_options_box.get_style_context().add_class (Gtk.STYLE_CLASS_LINKED);
        album_options_box.set_halign (Gtk.Align.CENTER);
        
       
        this.attach (album_options_box, 0, 3, 1, 1);
        
        for (int i = 0; i < current_album.get_song_count(); i++) {
        
            var event_box = new Gtk.EventBox ();
                
            var song = current_album.get_song_at_number(i);
        
            if (song != null) {
        
                var song_label = new Gtk.Label
                                     (song.title);
                                             
                song_label.set_size_request (-1, -1);
            
                song_label.set_alignment (0.0f, 0.5f);
                
                song_label.margin_top = 3;
                song_label.margin_bottom = 3;
                song_label.margin_start = 24;
                song_label.margin_end = 6;
                
                song_label.get_style_context().add_class ("sidebar-item");
                
                song_label.expand = false;
                                
                song_label.set_ellipsize (Pango.EllipsizeMode.END);
                song_label.set_max_width_chars (40);
                
                song_label.set_line_wrap (true);
                
                song_label.size_allocate.connect ((allocation) => {    
                    song_label.set_size_request (allocation.width - 50, -1);
                });
                         
                event_box.add (song_label);             
                event_box.button_press_event.connect (() => {
                    this.song_clicked (song);
                
                    return true;
                });
            
                event_box.name = "MusicSongList";
            
                this.attach (event_box, 0, i + 4, 1, 1);
            
            }
        }    
    }
    
    private void clear_widgets () {
        var children = this.get_children ();
        
        for (int iter = 0; iter < children.length(); iter++) {
            children.nth_data(iter).destroy ();
        }
    }
    
}

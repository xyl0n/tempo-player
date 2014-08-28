public class Tempo.AlbumView {
    
    public Gtk.FlowBox art_box;
    
    public Gtk.ScrolledWindow art_scrolled;
        
    string music_dir;
    
    private MusicManager music_files;
    
    public signal void album_image_clicked (AlbumObject album);
    
    public AlbumView () {
    
        art_box = new Gtk.FlowBox();
        art_scrolled = new Gtk.ScrolledWindow (null, null);
        
        music_files = new MusicManager ();
    
        for (int i = 0; i < music_files.album_objects.length(); i++) {
        
            AlbumObject album = new AlbumObject ();
            album = music_files.album_objects.nth_data(i);
        
            Gtk.Image image = album.album_art;
            
            image.set_pixel_size (128);
            image.xalign = 0.5f;
            image.yalign = 0.5f;
            
            var event_box = new Gtk.EventBox ();            
            event_box.add (image);
            //event_box.expand = false;
                        
            event_box.button_press_event.connect (() => {
                
                this.album_image_clicked (album);
                
                return true;
            });
                        
            var art_box_child = new Gtk.FlowBoxChild ();
            
            /*Gdk.RGBA selected_col = new Gdk.RGBA();
            selected_col.parse ("#ff0000");
            
            art_box_child.override_background_color(Gtk.StateFlags.NORMAL, selected_col);*/
                        
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 2);
            
            box.pack_start (event_box);
            
            var album_title = new Gtk.Label (album.title);
            album_title.expand = false;
            album_title.set_ellipsize (Pango.EllipsizeMode.END);
            album_title.set_max_width_chars (20);
            
            //album_title.get_style_context().set_scale (1.2);
            
            var artist_name = new Gtk.Label (album.artist);
            
            artist_name.get_style_context().add_class ("dim-label");
            artist_name.set_ellipsize (Pango.EllipsizeMode.END);
            artist_name.set_max_width_chars (20);
            artist_name.expand = false;
            
            box.pack_start (album_title, false, false);
            box.pack_start (artist_name, false, false);
            box.expand = false;
                        
            art_box_child.add (box);
            //art_box_child.expand = false;
                        
            art_box.insert (art_box_child, i);
            
            //album_art += button;                                                      
        }
        
        art_box.set_homogeneous (true);
        
        art_box.set_row_spacing (24);
        art_box.set_column_spacing (12);
        
        art_box.set_valign (Gtk.Align.START);
        
        art_box.margin_start = 24;
        art_box.margin_top = 24;
        art_box.margin_end = 24;
        art_box.margin_bottom = 24;
        
        art_box.set_selection_mode (Gtk.SelectionMode.NONE);
                
        art_scrolled.add (art_box);
        
        this.music_dir = Tracker.Sparql.escape_string
                        (Gst.filename_to_uri
                        (Environment.get_user_special_dir
                        (UserDirectory.MUSIC)));    
        
        art_scrolled.show();   
    }
        
    private bool on_image_click (Gdk.EventButton event) {
        //this.album_image_clicked ();
        return true;
    }
}

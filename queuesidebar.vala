public class Tempo.QueueSidebar : Gtk.Grid {
        
    private Gtk.Box item_box;
    
    private List<MediaObject> song_list;
    
    public signal void item_clicked (MediaObject media, int position);
    public signal void queue_clear_request ();
    
    public QueueSidebar () {
    
        song_list = new List<MediaObject> ();
        
        //this.get_style_context().add_class ("view");
    
        this.set_orientation (Gtk.Orientation.VERTICAL);
        this.expand = false;
        this.set_size_request (250, -1);
                        
        item_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        item_box.expand = false;
        
        // Heading for the sidebar
        
        var heading = new Gtk.Label ("Queue");
        heading.set_markup ("<b>Queue</b>");    
        heading.yalign = 0.5f;
        heading.xalign = 0;      
        heading.hexpand = true;
        heading.margin_start = 6;
        
        //Make it big
        
        var attributes = new Pango.AttrList ();
        var scale = Pango.attr_scale_new (1.2);
        
        attributes.insert (scale.copy());              
        heading.set_attributes (attributes);
        
        //Add a button to clear the queue
        
        var clear_button = new Gtk.Button.from_icon_name ("user-trash-symbolic", 
                                                          Gtk.IconSize.BUTTON);
        clear_button.margin_top = 3;
        clear_button.margin_start = 3;
        clear_button.margin_end = 3;
        clear_button.margin_bottom = 3;
        
        clear_button.clicked.connect (() => {
            queue_clear_request ();
        });
        
        var heading_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        heading_box.pack_start (heading, true, true);
        heading_box.pack_start (clear_button, false);
                
                        
        this.attach (heading_box, 0, 0, 1, 1);
        this.attach (item_box, 0, 1, 1, 1);
    }
    
    public void update_sidebar (int current_pos) {
        this.clear_widgets ();
                
        for (int i = 0; i < this.song_list.length(); i++) {
        
            var box = new Gtk.EventBox ();
            
            var current_song = song_list.nth_data (i);
        
            var name = new Gtk.Label (current_song.title);
            name.yalign = 0;
            name.xalign = 0;
            name.expand = false;
            name.margin_start = 12;
            name.margin_end = 12;
            name.margin_top = 3;
            name.margin_bottom = 3;
                                    
            name.set_ellipsize (Pango.EllipsizeMode.END);
            name.set_max_width_chars (20);
            
            if (i == current_pos) {
                name.set_markup ("<b>" + current_song.title + "</b>");
            } else if (i < current_pos) {
                name.get_style_context().add_class ("dim-label");
            }
            
            box.add (name);
                        
            box.button_press_event.connect (() => {
                                        
                var children = item_box.get_children ();
        
                for (int iter = 0; iter < children.length(); iter++) {
                    if (children.nth_data (iter) == box) {
                        item_clicked (current_song, iter);
                    }
                }
                
                return true;
            });
                        
            item_box.pack_start (box, false, false);
        }
                           
        item_box.show_all(); 
    }
        
    public void set_queue (List<MediaObject> songs) {
        // remove existing songs
        song_list.foreach ((entry) => {
            song_list.remove (entry);
        }); 
        
        //re-make list        
        song_list = songs.copy();
    }
       
    private void clear_widgets () {
        var children = this.item_box.get_children ();
        
        for (int iter = 0; iter < children.length(); iter++) {
            children.nth_data(iter).destroy ();
        }
    }   

}   

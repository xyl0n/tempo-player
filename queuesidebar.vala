public class Tempo.QueueSidebar : Gtk.Grid {
        
    private Gtk.Revealer item_revealer;
    private Gtk.Box item_box;
    
    private MediaObject[] song_list = { };
    
    public QueueSidebar () {
    
        this.set_orientation (Gtk.Orientation.VERTICAL);
        this.expand = false;
        this.set_size_request (200, -1);
        
        item_revealer = new Gtk.Revealer ();
        item_revealer.set_transition_type (Gtk.RevealerTransitionType.CROSSFADE);
                
        item_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        item_box.expand = false;
        //item_revealer.add (item_box);
        //this.attach (item_box, 0, 1, 1, 1);
        
        var heading = new Gtk.Label ("Queue");
        heading.set_markup ("<b>Queue</b>");    
        heading.yalign = 0;
        heading.xalign = 0;      
        heading.expand = false;
        heading.margin_top = 6;
        heading.margin_start = 6;
        
        var heading_separator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
        heading_separator.set_hexpand(true);
        heading_separator.margin_top = 3;
        heading_separator.margin_start = 6;
        heading_separator.margin_end = 12;
        heading_separator.margin_bottom = 3;
        this.attach (heading_separator, 0, 1, 1, 1);
        
        var attributes = new Pango.AttrList ();
        var scale = Pango.attr_scale_new (1.1);
        
        attributes.insert (scale.copy());
              
        heading.set_attributes (attributes);
        
        this.attach (heading, 0, 0, 1, 1);
        
        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        separator.expand = true;
        
        //this.attach (separator, 1, 0, 1, 1);
        
        //this.update_sidebar ();
    }
    
    public void update_sidebar () {
        this.clear_widgets ();
                
        for (int i = 0; i < this.song_list.length; i++) {
            var name = new Gtk.Label (song_list[i].title);
            name.yalign = 0;
            name.xalign = 0;
            name.expand = false;
            
            name.margin_start = 12;
            item_box.pack_start (name, false, false);
            //this.attach (name, 0, i + 1, 1, 1);
            stdout.printf ("%s\n", song_list[i].title);
        }
                        
        this.attach (item_box, 0, 2, 1, 1);   
        this.show ();  
    }
    
    public void set_queue (MediaObject[] songs) {
        song_list = songs;
    }
            
    private void clear_widgets () {
        var children = this.item_box.get_children ();
        
        for (int iter = 0; iter < children.length(); iter++) {
            children.nth_data(iter).destroy ();
        }
    }   

}   

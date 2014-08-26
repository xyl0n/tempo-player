public class Tempo.QueueSidebar : Gtk.Grid {
    
    private QueueManager current_queue;
    
    private Gtk.Revealer item_revealer;
    private Gtk.Box item_box;
    
    public QueueSidebar () {
    
        this.set_orientation (Gtk.Orientation.VERTICAL);
        this.expand = false;
        this.set_size_request (200, -1);
        
        item_revealer = new Gtk.Revealer ();
        item_revealer.set_transition_type (Gtk.RevealerTransitionType.CROSSFADE);
                
        item_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 3);
        item_revealer.add (item_box);
        //this.attach (item_revealer, 0, 0, 1, 1);
        
        this.update_sidebar ();
              
        current_queue = new QueueManager ();
        //current_queue.queue_changed.connect (on_queue_changed);
    }
    
    public void update_sidebar (MediaObject[] songs = null) {
        //this.clear_widgets ();
        
        var heading = new Gtk.Label ("Queue");
        heading.set_markup ("<b>Queue</b>");    
        heading.yalign = 0;    
        item_box.pack_start (heading);
        //this.attach (heading, 0, 0, 1, 1);
        
        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        separator.expand = true;
        
        this.attach (separator, 1, 0, 1, 1);
        
        for (int i = 0; i < songs.length; i++) {
            var name = new Gtk.Label (songs[i].title);
            item_box.pack_start (name);
            //this.attach (name, 0, i + 1, 1, 1);
            stdout.printf ("%s\n", songs[i].title);
        }
        
        this.attach (item_box, 0, 0, 1, 1);
        item_revealer.set_reveal_child (true);         
        this.show ();  
    }
        
    private void on_queue_changed () { //<---- put this in interface.vala and use add_media_to_sidebar
        var list = current_queue.get_queue ();
        
        for (int i = 0; i < list.length; i++) {
            
            var title = new Gtk.Label (list[i].title);
            this.attach (title, 0, i + 1, 1, 1);
        }
    }
    
    private void clear_widgets () {
        var children = this.get_children ();
        
        for (int iter = 0; iter < children.length(); iter++) {
            children.nth_data(iter).destroy ();
        }
    }   

}   

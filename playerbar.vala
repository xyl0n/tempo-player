public class Tempo.PlayerBar : Gtk.Grid {
    
    // Class for implementing a player bar        
    
    
    public Gtk.Box control_box;
    
    public Gtk.Button play_btn;
    public Gtk.Image play_img;
    public Gtk.Image pause_img;

    public Gtk.Button seek_forward_btn;
    public Gtk.Image seek_forward_img;
    
    public Gtk.Button seek_backward_btn;
    public Gtk.Image seek_backward_img;
        
    public Gtk.Grid media_info_grid;
    public Gtk.Box scale_layout;
    
    public Gtk.Scale media_scale;
    
    public Gtk.Label media_dur;
    public Gtk.Label media_pos;
    
    public Gtk.Box media_label_layout;
    
    public Gtk.Label media_title;
    public Gtk.Label media_artist;
    
    public Gtk.Label media_info_label;
    
    public PlayerBar () {
        setup_media_controls ();
        setup_media_scale ();
    }
    
    private void setup_media_controls () {
    
        //Create buttons for controlling the media
    
        play_btn = new Gtk.Button ();
        play_img = new Gtk.Image.from_icon_name (
                           "media-playback-start-symbolic",
                           Gtk.IconSize.LARGE_TOOLBAR);
        pause_img = new Gtk.Image.from_icon_name (
                            "media-playback-pause-symbolic",
                            Gtk.IconSize.LARGE_TOOLBAR);
        play_btn.set_image (pause_img);
                            
        seek_forward_btn = new Gtk.Button ();
        seek_forward_img = new Gtk.Image.from_icon_name (
                                   "media-seek-forward-symbolic",
                                   Gtk.IconSize.LARGE_TOOLBAR);
        seek_forward_btn.set_image (seek_forward_img);
        
        seek_backward_btn = new Gtk.Button ();
        seek_backward_img = new Gtk.Image.from_icon_name (
                                    "media-seek-backward-symbolic",
                                    Gtk.IconSize.LARGE_TOOLBAR);  
        seek_backward_btn.set_image (seek_backward_img);                
        
        //Create a Box to pack the control buttons in
        
        control_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        control_box.pack_start (seek_backward_btn);
        control_box.pack_start (play_btn);
        control_box.pack_start (seek_forward_btn);
        control_box.get_style_context().add_class (Gtk.STYLE_CLASS_LINKED);
        
        control_box.margin_top = 12;
        control_box.margin_start = 12;
        control_box.margin_end = 12;
        control_box.margin_bottom = 12;
        
        // Add the control box to the grid   
        this.attach (control_box, 0, 0, 1, 1);
    }
    
    private void setup_media_scale () {
        
        //Setup layouts
        media_info_grid = new Gtk.Grid ();
        scale_layout = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        
        //Setup a scale control for controlling the song position
        
        media_scale = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 50, 1);
        media_scale.hexpand = true;
        media_scale.set_draw_value (false);
                
        media_dur = new Gtk.Label ("0:00");
        media_pos = new Gtk.Label ("0:00");
        
        scale_layout.pack_start (media_pos, false);
        scale_layout.pack_start (media_scale, true);
        scale_layout.pack_start (media_dur, false);
        
        media_info_grid.attach (scale_layout, 0, 1, 1, 1);
        
        //Setup labels to show song information
        
        media_label_layout = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        
        media_title = new Gtk.Label ("Song");
        media_label_layout.pack_start (media_title, false);
        var by_label = new Gtk.Label ("by");
        media_label_layout.pack_start (by_label, false);
        media_artist = new Gtk.Label ("Artist");
        media_label_layout.pack_start (media_artist, false);
        
        media_info_label = new Gtk.Label ("<b>Song</b> by Artist");
        media_info_label.set_use_markup (true);
        
        media_label_layout.hexpand = true;
        
        media_info_grid.attach (media_info_label, 0, 0, 1, 1);
        media_info_grid.set_valign (Gtk.Align.CENTER);
        
        this.attach (media_info_grid, 1, 0, 1, 1);
    }
}

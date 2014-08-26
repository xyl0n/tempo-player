public class Tempo.Interface
{
    private Gtk.Grid song_layout;
    
    private Gtk.Grid window_layout;
    private Gtk.Paned album_pane;
    
    private AlbumSidebar album_sidebar;
    private Gtk.ScrolledWindow sidebar_scrolled;
    private Gtk.Revealer sidebar_revealer;
    
    private QueueSidebar queue_sidebar;
    
	private Gtk.HeaderBar header;
	
	private Gtk.TreeView song_view;
	private Gtk.ListStore song_store;
    private Gtk.ScrolledWindow song_view_scrolled;

    private Gtk.Revealer player_revealer;

    private Gtk.Grid player_grid;

    private Gtk.Grid control_grid;

    private Gtk.Button play_button;
    private Gtk.Image play_img;
    private Gtk.Image pause_img;
 
    private Gtk.Button seek_forward_button;
    private Gtk.Image seek_forward_img;
    
    private Gtk.Button seek_backward_button;
    private Gtk.Image seek_backward_img;
    
    private Gtk.Scale media_pos;
    private bool is_seeking;
    private Gtk.Label song_duration;
    private Gtk.Label song_position;
    private Gtk.Grid progress_grid;
    
    private Gtk.Label song_title;
    private Gtk.Label song_artist;
    private Gtk.Grid song_info;
        
    private Gtk.Stack view_stack;
    private Gtk.StackSwitcher view_switcher;
    
    private MusicManager manager;
    
    private StreamPlayer player;
    
    private AlbumView album_view;
    
    private QueueManager queue_manager;
        
    public bool app_running;
        
	public Interface (Gtk.Window window)
	{	
	    app_running = true;
	
	    this.manager = new MusicManager ();
	    this.player = new StreamPlayer();
	    this.album_view = new AlbumView();
	    this.queue_manager = new QueueManager ();
	    queue_manager.queue_changed.connect (on_queue_changed);
	    
	    album_view.album_image_clicked.connect (on_album_clicked);
	    
	    window_layout = new Gtk.Grid();
	    album_pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
	    
	    album_sidebar = new AlbumSidebar ();
	    album_sidebar.song_clicked.connect (on_sidebar_song_click);
	    sidebar_scrolled = new Gtk.ScrolledWindow (null, null);
	    sidebar_scrolled.add (album_sidebar);
	    sidebar_scrolled.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
	    sidebar_revealer = new Gtk.Revealer ();
	    sidebar_revealer.add (sidebar_scrolled);
	    sidebar_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_LEFT);
	    sidebar_revealer.set_transition_duration (20);
	    
	    album_sidebar.has_children.connect (() => {
	        sidebar_revealer.set_reveal_child (true);
	    });
	    
	    player.media_changed.connect (on_media_changed);
	    player.media_playing.connect (on_media_play);
	    player.media_paused.connect (on_media_pause);
        player.media_position_changed.connect (on_media_position_change);
        player.media_duration_changed.connect (on_media_duration_change);
	    
        this.song_layout = new Gtk.Grid();
        //window.add(song_layout);
                
		this.setup_header ();
		window.set_titlebar (header);

        this.setup_player_bar_images();
        this.setup_player_bar ();
        
        GLib.Timeout.add (1000, (SourceFunc) this.update_media_controls);
                
        window.add (this.window_layout);
        
        this.setup_music_list ();
        
        for (int i = 0; i < manager.song_files.length; i++) {               
            this.add_song_to_list (manager.song_files[i].get_tag_title(),
                                   manager.song_files[i].get_tag_album(), 
                                   manager.song_files[i].get_tag_artist());
        }

        song_layout.show();
        		
        view_stack = new Gtk.Stack ();		
        		
		view_switcher.set_stack (view_stack);
		
		album_pane.pack1 (album_view.art_scrolled, true, true);
		album_pane.pack2 (sidebar_revealer, false, false);
		album_pane.show();
		
		queue_sidebar = new QueueSidebar ();
		
		Gtk.Box albums_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		//albums_box.pack_start (queue_sidebar, false); <--- USE THIS ONCE QUEUE SIDEBAR IS WORKING
		albums_box.pack_start (album_pane, true);
		albums_box.show ();	
		
		view_stack.add_titled (albums_box, "albums", "Albums");
		view_stack.add_titled (this.song_layout, "songs", "Library");
		
		view_stack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
						
		window_layout.attach (view_stack, 0, 0, 1, 1);
		window_layout.attach (player_revealer, 0, 2, 1, 1);
        window_layout.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1, 1, 1);
        
        view_stack.set_visible_child_name ("albums");
	}

	private void setup_header()
	{
		header = new Gtk.HeaderBar (); 
		header.set_show_close_button (true);
				
		view_switcher = new Gtk.StackSwitcher ();
		
		header.set_custom_title(view_switcher);
	}

    private void setup_player_bar () {

        player_grid = new Gtk.Grid();
        player_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_TOOLBAR);
        player_grid.show ();
        
        player_revealer = new Gtk.Revealer ();
        player_revealer.add (player_grid);
        player_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_UP);

        media_pos = new Gtk.Scale.with_range (Gtk.Orientation.HORIZONTAL, 0, 50, 1);
        media_pos.hexpand = true;
        media_pos.set_draw_value (false);
        
        is_seeking = false;
        
        media_pos.button_release_event.connect (on_media_seeked);
        media_pos.button_press_event.connect (() => {
            this.is_seeking = true;
            
            return false;
        });
        //media_pos.value_changed.connect (on_scale_value_changed);
                                        
        control_grid = new Gtk.Grid ();
        control_grid.get_style_context().add_class (Gtk.STYLE_CLASS_LINKED);
                
        control_grid.set_margin_top (12);
        control_grid.set_margin_bottom (12);
        control_grid.set_margin_start (6);
        control_grid.set_margin_end (6);    
                                                       
        play_button = new Gtk.Button();        
        play_button.set_image (this.pause_img);
        play_button.get_style_context().add_class (Gtk.STYLE_CLASS_LINKED);
        control_grid.attach (play_button, 1, 0, 1, 1);
        
        seek_forward_button = new Gtk.Button ();
        seek_forward_button.set_image (this.seek_forward_img);
        seek_forward_button.get_style_context().add_class (Gtk.STYLE_CLASS_LINKED);
        control_grid.attach (seek_forward_button, 2, 0, 1, 1);
        
        seek_backward_button = new Gtk.Button ();
        seek_backward_button.set_image (this.seek_backward_img);
        seek_backward_button.get_style_context().add_class (Gtk.STYLE_CLASS_LINKED);
        seek_backward_button.get_style_context().add_class (Gtk.STYLE_CLASS_LEFT);
        control_grid.attach (seek_backward_button, 0, 0, 1, 1);
        
        play_button.clicked.connect (on_play_button_clicked);
                
        song_info = new Gtk.Grid ();
        
        song_info.set_margin_top (6);
        song_info.set_margin_bottom (6);
        song_info.set_margin_start (6);
        song_info.set_margin_end (6);  
        
        progress_grid = new Gtk.Grid ();
               
        song_title = new Gtk.Label ("Song Title by Artist");
        //song_title.set_alignment (0, 0);
        song_info.attach (song_title, 0, 0, 1, 1);
        
        song_duration = new Gtk.Label ("0:00");
        song_position = new Gtk.Label ("0:00");
        //song_artist = new Gtk.Label ("Artist");
        //song_artist.set_alignment (0, 0);
        //song_info.attach (song_artist, 0, 1, 1, 1);
        progress_grid.attach(song_position, 0, 0, 1, 1);
        progress_grid.attach (media_pos, 1, 0, 1, 1);
        progress_grid.attach (song_duration, 2, 0, 1, 1);
        
        song_info.attach (progress_grid, 0, 1, 1, 1);            
        
        player_grid.attach (control_grid, 0, 0, 1, 1);
        player_grid.attach (song_info, 1, 0, 1, 1);
        //player_grid.attach (media_pos, 2, 0, 1, 1);
        
        player_grid.show();   
        
        song_layout.show();

    }
    
    public void update_media_controls () {
        
        if (!is_seeking) {
                            
            var pos = player.get_song_position();
            
            int64 seconds = (pos / 1000000000);
            int64 minutes = (seconds / 60);
        
            int64 remainder = seconds - (minutes * 60);
        
            this.media_pos.set_value (seconds);
        
            string minute_string = minutes.to_string ();
        
            string remainder_string = remainder.to_string ();
        
            if (remainder < 10) {
                remainder_string = "0" + remainder_string;
            }
                    
            this.song_position.set_label (minute_string + ":" + 
                                          remainder_string);
        }
    }
    
    private void setup_player_bar_images () {
    	play_img = new Gtk.Image.from_icon_name (
                           "media-playback-start-symbolic", 
                           Gtk.IconSize.LARGE_TOOLBAR);
                           
        pause_img = new Gtk.Image.from_icon_name (
                           "media-playback-pause-symbolic", 
                           Gtk.IconSize.LARGE_TOOLBAR);
                           
        seek_forward_img = new Gtk.Image.from_icon_name (
                           "media-seek-forward-symbolic", 
                           Gtk.IconSize.LARGE_TOOLBAR);
                           
        seek_backward_img = new Gtk.Image.from_icon_name (
                           "media-seek-backward-symbolic", 
                           Gtk.IconSize.LARGE_TOOLBAR);                           
    }
    
    private void setup_music_list () {
        song_store = new Gtk.ListStore (3, typeof (string), typeof (string), 
                                           typeof (string));
                                           
        song_view_scrolled = new Gtk.ScrolledWindow (null, null);

        song_view = new Gtk.TreeView.with_model (song_store);
        song_view.expand = true;
        song_view.set_activate_on_single_click (false);
        song_view.row_activated.connect (on_row_activated);
        
        song_view.show();
        song_view_scrolled.add (song_view);
        this.song_layout.attach (song_view_scrolled, 0, 0, 1, 1);
        song_layout.show();
        
        Gtk.CellRendererText cell = new Gtk.CellRendererText ();
        song_view.insert_column_with_attributes (-1, "Song", cell, "text", 0);
        song_view.insert_column_with_attributes (-1, "Album", cell, "text", 1);
        song_view.insert_column_with_attributes (-1, "Artist", cell, "text", 2);
    }
    
    private void add_song_to_list (string song_title, string album_name, string artist_name) {
            
        Gtk.TreeIter song_iter;
    
        song_store.append (out song_iter);
        song_store.set (song_iter, 0, song_title, 1, album_name, 2, artist_name);
    }
    
    private void on_row_activated (Gtk.TreePath path, Gtk.TreeViewColumn column) {
        
        player.stop();
        
        int[] i = { };
        
        var selection = this.song_view.get_selection();
        
        Gtk.TreeModel view_model;
        Gtk.TreeIter view_iter;
        Gtk.TreePath view_path; 

        if (selection.get_selected(out view_model, out view_iter)) {
            
            view_path = view_model.get_path(view_iter);
            
            i = view_path.get_indices ();
        }   
                        
        player.set_media_file(manager.song_files[i[0] + 1].media_uri);
        player.play();
    }
    
    private void on_play_button_clicked () {
        if (player.is_playing()) {
            player.pause();           
        }
        else if (!player.is_playing()) {
            player.play ();
        }
    }
    
    private void on_media_changed () {
        string file_uri = player.get_current_uri ();
        
        MediaObject media_obj;
        
        manager.find_from_uri (file_uri, out media_obj);
        
        this.song_title.set_label (media_obj.get_tag_title() + " by " + media_obj.get_tag_artist());
    }
    
    private void on_media_play () {
    
        if (!player_revealer.get_child_revealed()) {
            player_revealer.set_reveal_child(true);
        }
    
        if (play_button.get_image() == this.pause_img) {
            
        } else {
            play_button.set_image (pause_img);
        }        
        
        this.update_media_controls();
    }
    
    private void on_media_pause () {
        if (play_button.get_image () == this.play_img) {
            
        } else {
            play_button.set_image (play_img);
        }
    }    
    
    private void on_media_position_change (int64 position) {
        this.update_media_controls ();
    }
    
    private bool on_media_seeked (Gdk.EventButton event) {
        
        var pos = media_pos.get_value ();
        pos = pos * 1000000000;
        
        player.seek ((int64)pos);
        
        is_seeking = false;
        
        return false;
    } 

    private void on_media_duration_change (int64 duration) {

        int64 seconds = (duration / 1000000000);
        int64 minutes = (seconds / 60);
        
        int64 remainder = seconds - (minutes * 60);
        
        media_pos.set_range (0, seconds);
        
        string minute_string = minutes.to_string ();
        
        string remainder_string = remainder.to_string ();
        
        if (remainder < 10) {
            remainder_string = "0" + remainder_string;
        }
        
        this.song_duration.set_label (minute_string + ":" + remainder_string);
        
        stdout.printf ("\nLENGTH: %" + int64.FORMAT + ":%" + int64.FORMAT, minutes, remainder);
    }
    
    private void on_album_clicked (AlbumObject album) {
        stdout.printf ("\nALBUM: %s\n", album.title);
        this.album_sidebar.set_current_album (album);
        this.album_sidebar.show_all();
    }
    
    private void on_sidebar_song_click (MediaObject song) {
        this.player.stop();
        this.player.set_media_file (song.media_uri);
        queue_manager.add_media_to_queue (song);
        this.player.play();
    }
    
    private void on_queue_changed () {
        stdout.printf ("QUEUE:\n");
        MediaObject[] current = queue_manager.get_queue ();
        
        //queue_sidebar.update_sidebar (current); FIXME 
    }
}

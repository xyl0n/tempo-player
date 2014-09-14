public class Tempo.Interface
{
    public Utils utils;

    private Gtk.Grid song_layout;
    
    private Gtk.Grid window_layout;
    private Gtk.Paned album_pane;
    
    public AlbumSidebar album_sidebar;
    private Gtk.ScrolledWindow sidebar_scrolled;
    private Gtk.Revealer sidebar_revealer;
    
    public QueueSidebar queue_sidebar;
    public Gtk.Revealer queue_revealer;
    public Gtk.Button queue_visible_btn;
    public Gtk.Image queue_show_img;
    public Gtk.Image queue_hide_img;
    
	private Gtk.HeaderBar header;
	
	private Gtk.TreeView song_view;
	private Gtk.ListStore song_store;
    private Gtk.ScrolledWindow song_view_scrolled;

    public Gtk.Revealer player_revealer;

    private Gtk.Grid player_grid;
    
    public bool is_seeking = false;
        
    private Gtk.Stack view_stack;
    private Gtk.StackSwitcher view_switcher;
    
    public MusicManager manager;
    public StreamPlayer player;
    public AlbumView album_view;
    public QueueManager queue_manager;
    public PlayerBar player_bar;
        
    private SignalHandler signal_handler;    
        
    public bool app_running;
        
    public signal void stream_playing ();
    public signal void stream_finished (); 
        
	public Interface (Gtk.Window window)
	{	
	    app_running = true;
	    
	    utils = new Utils (this);
	    
	    signal_handler = new SignalHandler (this);	    
	
	    manager = new MusicManager ();
	    player = new StreamPlayer();
	    player.end_of_stream.connect (signal_handler.on_current_song_end);
	    
	    album_view = new AlbumView();
	    queue_manager = new QueueManager ();
	    
	    queue_manager.queue_changed.connect (signal_handler.on_queue_changed);
	    queue_manager.current_position_changed.connect (signal_handler.on_queue_position_changed);
	    
	    album_view.album_image_clicked.connect (signal_handler.on_album_clicked);
	    
	    window_layout = new Gtk.Grid();
	    album_pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
	    
	    album_sidebar = new AlbumSidebar ();
	    album_sidebar.song_clicked.connect (signal_handler.on_sidebar_song_click);
	    album_sidebar.album_to_queue.connect (signal_handler.on_album_add);
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
	    	    
        this.song_layout = new Gtk.Grid();
        //window.add(song_layout);
                
		this.setup_header ();
		window.set_titlebar (header);

        // Setup the playerbar to control the media

        player_revealer = new Gtk.Revealer ();
        player_revealer.add (player_grid);
        player_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_UP);
        
        player_bar = new PlayerBar ();
        player_revealer.add (player_bar);
        
        player_bar.play_btn.clicked.connect (signal_handler.on_play_button_clicked);
        player_bar.seek_forward_btn.clicked.connect (signal_handler.on_forward_seek);
        player_bar.seek_backward_btn.clicked.connect (signal_handler.on_backward_seek);
        player_bar.shuffle_btn.clicked.connect (signal_handler.on_shuffle);

        player_bar.media_scale.button_release_event.connect (signal_handler.on_media_seeked);
        player_bar.media_scale.button_press_event.connect (() => {
            this.is_seeking = true;
            
            return false;
        });

        //Schedule the media scale to be updated at regular intervals
        GLib.Timeout.add (1000, (SourceFunc) this.update_media_controls);
                
        window.add (this.window_layout);
        
        //Setup the Library view - TODO: redo this
        
        this.setup_music_list ();
        
        for (int i = 0; i < manager.song_files.length(); i++) {               
            this.add_song_to_list (manager.song_files.nth_data(i).get_tag_title(),
                                   manager.song_files.nth_data(i).get_tag_album(), 
                                   manager.song_files.nth_data(i).get_tag_artist());
        }

        song_layout.show();
        		
        view_stack = new Gtk.Stack ();		
        		
		view_switcher.set_stack (view_stack);
		
		album_pane.pack1 (album_view.art_scrolled, true, true);
		album_pane.pack2 (sidebar_revealer, false, false);
		album_pane.show();
		
		queue_sidebar = new QueueSidebar ();
		queue_sidebar.item_clicked.connect (signal_handler.on_queue_item_click);
		queue_sidebar.queue_clear_request.connect (signal_handler.on_queue_clear_request);
		var queue_scroll = new Gtk.ScrolledWindow (null, null);
		queue_scroll.add (queue_sidebar);
		queue_scroll.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		queue_revealer = new Gtk.Revealer ();
		queue_revealer.add (queue_scroll);
		queue_revealer.set_transition_type (Gtk.RevealerTransitionType.SLIDE_RIGHT);
		
		// Queue visibility button
		
		queue_show_img = new Gtk.Image.from_icon_name ("go-next-symbolic", Gtk.IconSize.BUTTON);
		queue_hide_img = new Gtk.Image.from_icon_name ("go-previous-symbolic", Gtk.IconSize.BUTTON);
		
		queue_visible_btn = new Gtk.Button ();
		queue_visible_btn.set_image (queue_show_img);
		queue_visible_btn.valign = Gtk.Align.CENTER;
		queue_visible_btn.halign = Gtk.Align.CENTER;
        queue_visible_btn.margin_start = 6;
        queue_visible_btn.margin_end = 6;
        
        queue_visible_btn.clicked.connect (signal_handler.queue_reveal_request);           
		
		// Album view
		
		Gtk.Box albums_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		albums_box.pack_start (queue_revealer, false);
		albums_box.pack_start (new Gtk.Separator (Gtk.Orientation.VERTICAL), false);
		albums_box.pack_start (queue_visible_btn, false, false);
		albums_box.pack_start (album_pane, true);
		albums_box.show ();	
		
		view_stack.add_titled (albums_box, "albums", "Albums");
		view_stack.add_titled (this.song_layout, "songs", "Library");
		
		view_stack.set_transition_type (Gtk.StackTransitionType.CROSSFADE);
						
		window_layout.attach (view_stack, 0, 0, 1, 1);
		window_layout.attach (player_revealer, 0, 2, 1, 1);
        window_layout.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 1, 1, 1);
        
        view_stack.set_visible_child_name ("albums");
         
        
        player.media_changed.connect (signal_handler.on_media_changed);
	    player.media_playing.connect (signal_handler.on_media_play);
	    player.media_paused.connect (signal_handler.on_media_pause);
        player.media_position_changed.connect (signal_handler.on_media_position_change);
        player.media_duration_changed.connect (signal_handler.on_media_duration_change);
	}

	private void setup_header() {
		header = new Gtk.HeaderBar (); 
		header.set_show_close_button (true);
				
		view_switcher = new Gtk.StackSwitcher ();
		
		var properties_button = new Gtk.Button.from_icon_name ("document-properties-symbolic",
		                                                   Gtk.IconSize.BUTTON);
		                                                   
        header.pack_end (properties_button);		       
        
        /*var properties_popover = new Gtk.Popover (properties_button);
        properties_button.clicked.connect (() => {
            if (properties_popover.get_visible()) {
                properties_popover.hide();
            } else {
                properties_popover.show_all();
            }
        });
        
        var popover_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        var settings_btn = new Gtk.MenuItem.with_label ("Settings");
        //settings_btn.get_style_context().add_class (Gtk.STYLE_CLASS_MENUITEM);
        var about_btn = new Gtk.MenuItem.with_label ("About");
        //about_btn.get_style_context().add_class (Gtk.STYLE_CLASS_MENUITEM);
        popover_box.pack_start (settings_btn);
        popover_box.pack_start (about_btn);
                                                            
        properties_popover.add (popover_box);*/                                                    
                                                    
		//header.set_custom_title(view_switcher);
	}
    
    public void update_media_controls () {
        
        if (!is_seeking) {
                            
            var pos = player.get_song_position();
            
            int64 seconds = (pos / 1000000000);
            int64 minutes = (seconds / 60);
        
            int64 remainder = seconds - (minutes * 60);
        
            player_bar.media_scale.set_value (seconds);
        
            string minute_string = minutes.to_string ();
        
            string remainder_string = remainder.to_string ();
        
            if (remainder < 10) {
                remainder_string = "0" + remainder_string;
            }
                    
            player_bar.media_pos.set_label (minute_string + ":" + 
                                          remainder_string);
        }
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
        
        player.play();
    }
}

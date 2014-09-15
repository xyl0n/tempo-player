public class Tempo.SignalHandler {
       
    private Interface _ui;
        
    public SignalHandler (Interface ui) {
        _ui = ui;
    }
    
    public void on_play_button_clicked () {
        if (_ui.player.is_playing()) {
            _ui.player.playbin.set_state(Gst.State.PAUSED);
        } else {
            _ui.player.playbin.set_state(Gst.State.PLAYING);
        }
    }
    
    public void on_forward_seek () {
        MediaObject? media = _ui.queue_manager.get_next_media ();
        
        // If there is more media    
        if (media != null) {          
            _ui.utils.switch_to_media (media);
            if (!_ui.queue_manager.shuffle_mode) {
                _ui.queue_manager.increment_current_position();
            }
        } else {
            // Otherwise, skip to end of current song
            _ui.player.seek (_ui.player.get_song_duration());
        }
    }
    
    public void on_backward_seek () {
        MediaObject? media = _ui.queue_manager.get_prev_media ();
            
        // If there is more media  
        if (media != null) {          
            _ui.utils.switch_to_media (media);
            _ui.queue_manager.decrement_current_position();
        } else {
            // Otherwise, go to start of song
            _ui.player.seek (1); // Setting it to 0 crashes everything, don't do it
        }
    }
    
    
    public void on_media_changed () {
    
        string file_uri = _ui.player.get_current_uri ();
        MediaObject media_obj;
        
        _ui.manager.find_from_uri (file_uri, out media_obj);
        
        _ui.queue_manager.current_media = media_obj;  
        
        _ui.player_bar.media_info_label.set_label ("<b>" + media_obj.get_tag_title() 
                                                + "</b> by " + media_obj.get_tag_artist());                                                                                 
                                                                                            
    }
    
    public void on_media_play () {
    
        if (!_ui.player_revealer.get_child_revealed()) {
            _ui.player_revealer.set_reveal_child(true);
        }
    
        _ui.player_bar.play_btn.set_image (_ui.player_bar.pause_img); 
        
        _ui.update_media_controls();
        
        _ui.stream_playing ();
    }
        
    
    public void on_media_pause () {
        _ui.player_bar.play_btn.set_image (_ui.player_bar.play_img);
    }    
    
    public bool on_media_seeked (Gdk.EventButton event) {
        
        var pos = _ui.player_bar.media_scale.get_value ();
        pos = pos * 1000000000;
        
        _ui.player.seek ((int64)pos);
        
        _ui.is_seeking = false;
        
        return false;
    } 
    
    public void on_media_position_change (int64 position) {
        _ui.update_media_controls ();
    }
    
    public void on_media_duration_change (int64 duration) {

        int64 seconds = (duration / 1000000000);
        int64 minutes = (seconds / 60);
        
        int64 remainder = seconds - (minutes * 60);
        
        _ui.player_bar.media_scale.set_range (0, seconds);
        
        string minute_string = minutes.to_string ();
        
        string remainder_string = remainder.to_string ();
        
        if (remainder < 10) {
            remainder_string = "0" + remainder_string;
        }
        
        _ui.player_bar.media_dur.set_label (minute_string + ":" + remainder_string);
    }

    public void on_album_clicked (AlbumObject album) {
        _ui.album_sidebar.set_current_album (album);
        _ui.album_sidebar.show_all();
    }
    
    public void on_sidebar_song_click (MediaObject song) {
        
        //Only play the song if the queue is empty
        
        if (_ui.queue_manager.is_empty ()) {
            
            _ui.queue_manager.set_current_position(0); //set position of queue to 0 (first song)
            
            _ui.player.set_media_file (song.media_uri);
            _ui.player.play();
            
            _ui.stream_playing();
        } else if (_ui.queue_manager.is_at_end()) {
            _ui.queue_manager.increment_current_position(); //Increase position
            
            _ui.player.set_media_file (song.media_uri);
            _ui.player.play();
        }
        
        _ui.queue_manager.add_media_to_queue (song); //Add the current media to the queue
    }
    
    public void on_album_add (AlbumObject album) {
        for (int i = 0; i < album.get_song_count(); i++) {
            MediaObject? song = album.get_song_at_number (i);
            if (song != null) {
                if (_ui.queue_manager.is_empty() && i == 0) {
                    _ui.player.set_media_file (song.media_uri);
                    _ui.queue_manager.set_current_position(0);
                    _ui.player.play ();
                }
                _ui.queue_manager.add_media_to_queue (song);
            }
        }
    }
    
    public void on_queue_item_click (MediaObject song, int item_number) {
        
        _ui.player.stop ();
        _ui.player.set_media_file (song.media_uri);
        _ui.player.play ();
                
        _ui.queue_manager.set_current_position(item_number);
    }
    
    public void on_queue_changed () {
        unowned List<MediaObject> current =_ui.queue_manager.queue;

        _ui.queue_sidebar.set_queue (current);      
        _ui.queue_sidebar.update_sidebar (_ui.queue_manager.get_current_position());
        
        if (!_ui.queue_revealer.get_child_revealed()) {
            _ui.queue_revealer.set_reveal_child(true);
            _ui.queue_visible_btn.show ();
            _ui.queue_visible_btn.set_image (_ui.queue_hide_img);
        }

        _ui.queue_sidebar.show_all ();
    }
    
    public void on_current_song_end () {
        
        if (!_ui.queue_manager.is_at_end()) {            
            MediaObject? media = _ui.queue_manager.get_next_media ();
            
            if (media != null) {      
                _ui.utils.switch_to_media (media);
                if (!_ui.queue_manager.shuffle_mode) {
                    _ui.queue_manager.increment_current_position();
                }
            } else {
                _ui.player_revealer.set_reveal_child (false);
                _ui.stream_finished ();
                return;
            }
        } else {
            _ui.player_revealer.set_reveal_child (false);
        }
        
        _ui.stream_finished ();
    }

    public void on_queue_clear_request () {
        _ui.player.stop ();
        _ui.player_revealer.set_reveal_child (false);
        _ui.stream_finished ();
        _ui.queue_manager.clear_queue ();
    }
    
    public void on_queue_position_changed () {
        _ui.queue_sidebar.update_sidebar (_ui.queue_manager.get_current_position());
        _ui.queue_manager.played.append(_ui.queue_manager.get_current_position());
    }
    
    public void queue_reveal_request () {
        if (_ui.queue_revealer.get_child_revealed ()) {
            _ui.queue_revealer.set_reveal_child (false); //Hide queue sidebar
            _ui.queue_visible_btn.set_image (_ui.queue_show_img);
        } else {
            _ui.queue_revealer.set_reveal_child (true); //Show queue sidebar
            _ui.queue_visible_btn.set_image (_ui.queue_hide_img);
        }
    }
    
    public void on_shuffle () {
        
        // If not currently shuffling        
        if (!_ui.queue_manager.shuffle_mode) {
            _ui.queue_manager.shuffle_mode = true; //Set shuffle to on
            _ui.player_bar.shuffle_btn.set_image 
                (_ui.player_bar.shuffle_on_img);
        } else {
            _ui.queue_manager.shuffle_mode = false;
            _ui.player_bar.shuffle_btn.set_image 
                (_ui.player_bar.shuffle_off_img);
        }
    }
}

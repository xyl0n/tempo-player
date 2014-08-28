public class Tempo.SignalHandler {
       
    private Interface _ui;
        
    public SignalHandler (Interface ui) {
        _ui = ui;
    }
    
    public void on_play_button_clicked () {
        if (_ui.player.is_playing()) {
            _ui.player.pause ();
            stdout.printf ("PAUSING");
        } else {
            _ui.player.play ();
            stdout.printf ("PLAYING");
        }
    }
    
    public void on_media_changed () {
        string file_uri = _ui.player.get_current_uri ();
        MediaObject media_obj;
        
        _ui.manager.find_from_uri (file_uri, out media_obj);
        
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
        _ui.player.stop();
        _ui.player.set_media_file (song.media_uri);
        _ui.queue_manager.add_media_to_queue (song);
        _ui.player.play();
    }
    
    public void on_queue_changed () {
        MediaObject[] current =_ui.queue_manager.get_queue ();

        _ui.queue_sidebar.set_queue (current);      
        _ui.queue_sidebar.update_sidebar ();

        _ui.queue_sidebar.show_all ();
    }
}

public class Tempo.Utils {
 
    private Interface _ui;
 
    public Utils (Interface ui) {
        this._ui = ui;
    }
    
    public void switch_to_media (MediaObject song) {
        _ui.player.stop ();
        _ui.player.set_media_file (song.media_uri);
        _ui.player.play ();
    }   
}

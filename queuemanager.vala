public class Tempo.QueueManager {
    
    private MediaObject[] queue = { };
    
    public signal void queue_changed ();
    
    public QueueManager () {
    
    }
    
    public void add_media_to_queue (MediaObject song) {
        queue += song;
        queue_changed ();
    }
    
    public void add_album_to_queue (AlbumObject album) {
        
    }
    
    public void clear_queue () {
        queue = { };
        queue_changed ();
    }
    
    public MediaObject[] get_queue () {
        return queue;
    }
}

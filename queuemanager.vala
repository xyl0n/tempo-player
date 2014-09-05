public class Tempo.QueueManager {
    
    public List<MediaObject> queue;
    
    public signal void queue_changed ();
    public signal void current_position_changed ();
    
    public MediaObject current_media;
    
    public bool shuffle_mode = false;
    
    private int current_position = -1;
    
    public QueueManager () {
        queue = new List<MediaObject>();
    }
    
    public void add_media_to_queue (MediaObject song) {
        queue.append(song);
        queue_changed ();
    }
    
    public void add_album_to_queue (AlbumObject album) {
        
    }
    
    public void clear_queue () {
        queue.foreach ((entry) => {
            queue.remove (entry);
        });
        current_position = -1;
        queue_changed ();
    }
    
    public List<MediaObject>? get_queue () {
        if (queue != null) {
            return queue.copy();
        }
        
        return null;
    }
    
    public bool is_empty () {
        if (current_position == -1) {
            return true;
        }
        
        return false;
    }
    
    public bool is_at_end () {
        
        /*unowned List<MediaObject>? last_item = queue.last ();                 
                
        if (current_media != null) {
            if (current_media == last_item.data) { //Wont work if there are multiple instances of one song
                return true;
            }
        }
        
        return false;*/
        
        stdout.printf ("\n%d, %d\n", current_position, (int)queue.length());
        if (current_position == (queue.length() - 1)) {
            return true;
        }
        
        return false;
    }
    
          
    public MediaObject? get_next_media () {
                               
        // If there are songs in the queue                       
        if (current_position != -1) {
            // If not on shuffle mode
            if (!shuffle_mode) {
                // If there is a song after the current one
                if (queue.nth(current_position + 1) != null) {
                    //increment_current_position ();
                    return queue.nth_data (current_position + 1);
                }
            } else {
                // If shuffling 
                Random.set_seed ((uint32)GLib.get_real_time ());
                var rand = Random.int_range (0, (int32) (queue.length() - 1));
                set_current_position (rand);
                return queue.nth_data (rand);
            }
        }
        
        return null; //There is no more media
    }
    
    public MediaObject? get_prev_media () {
                               
        // If there are songs in the queue                       
        if (current_position != -1) {
            if (!shuffle_mode) {
                // If there is a song before the current one
                if (queue.nth(current_position - 1) != null) {
                    //decrement_current_position ();
                    return queue.nth_data (current_position - 1);
                }
            } else {
                Random.set_seed ((uint32)GLib.get_real_time ());
                var rand = Random.int_range (0, (int32) (queue.length() - 1));
                set_current_position (rand);
                return queue.nth_data (rand);
            }
        }
        
        return null; //There is no media before it
    }
    
    public void set_current_position (int val) {
        current_position = val;
        current_position_changed ();
    }
    
    public int get_current_position () {
        return current_position;
    } 
    
    public void increment_current_position () {
        current_position++;
        current_position_changed ();
    }   

    public void decrement_current_position () {
        current_position--;
        current_position_changed ();
    } 
}

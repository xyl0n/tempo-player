public class Tempo.QueueManager {
    
    public List<MediaObject> queue;
    public List<int> played;
        
    public signal void queue_changed ();
    public signal void current_position_changed ();
    
    public MediaObject current_media;
    
    public bool shuffle_mode = false;
    
    private int current_position = -1;
    
    public QueueManager () {
        queue = new List<MediaObject>();
        played = new List<int>();
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
        played.foreach ((entry) => {
            played.remove (entry);
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
        if (current_position == (queue.length() - 1) && shuffle_mode == false &&
            current_position != 0) {
            return true;
        }
        
        return false;
    }

    private int get_rand () {
        Random.set_seed ((uint32)GLib.get_real_time ());
        int rand = Random.int_range (0, (int32) (queue.length() - 1));
        
        stdout.printf ("rand: %d\n,", rand);
        for (int i = 0; i < played.length(); i++) {
            stdout.printf ("%d\n,", played.nth_data(i));
            if (rand == played.nth_data(i)) {
                return get_rand();
            }
        }   
        
        return rand;
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
            }
            else {
                // If shuffling
                stdout.printf ("played: %d\n", (int)played.length());
                if (played.length() == queue.length()) {
                    stdout.printf ("ALL HAVE BEEN PLAYED\n");
                    return null; // All songs have been played on shuffle
                } else {
                    //If there is only one song left
                    if (played.length() == queue.length() - 1) {
                        stdout.printf ("ONLY ONE SONG LEFT\n");
                        for (int i = 0; i < queue.length(); i++) {
                            //Find the song that hasn't been played
                            if (played.find(i) == null) {
                                set_current_position (i);
                                return queue.nth_data (i);
                            }
                        }  
                    }
                    int rand = get_rand();
                    set_current_position (rand);
                    return queue.nth_data (rand);
                }
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
        stdout.printf ("incrementing\n");
        current_position++;
        current_position_changed ();
    }   

    public void decrement_current_position () {
        current_position--;
        current_position_changed ();
    } 
}

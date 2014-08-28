using Gst;

public class Tempo.StreamPlayer {
    public dynamic Gst.Element playbin;
    
    private string media_uri;
    
    public signal void media_changed ();
    public signal void media_paused ();
    public signal void media_playing ();
    public signal void media_position_changed (int64 media_pos);
    public signal void media_duration_changed (int64 duration);
    public signal void end_of_stream ();
        
    private MainLoop loop = new MainLoop();    
        
    public StreamPlayer () {
        playbin = Gst.ElementFactory.make ("playbin", "play");
        
        Gst.Bus bus = playbin.get_bus ();
        bus.add_watch (0, bus_callback);
        
        playbin.set_state(Gst.State.NULL);
        
        media_uri = " ";      
    }

        
    private bool bus_callback (Gst.Bus bus, Gst.Message message) {
        switch (message.type) {
        case Gst.MessageType.ERROR:
            GLib.Error err;
            string debug;
            message.parse_error (out err, out debug);
            stdout.printf ("Error: %s\n", err.message);
            break;
        case MessageType.EOS:
            stdout.printf ("end of stream\n");
            end_of_stream ();
            break;
        case MessageType.STATE_CHANGED:
            Gst.State old_state;
            Gst.State new_state;
            Gst.State pending;
            message.parse_state_changed (out old_state, out new_state,
                                         out pending);
            //stdout.printf ("state changed: %s->%s:%s\n",
            //               oldstate.to_string (), newstate.to_string (),
            //               pending.to_string ());
            
            if (new_state == Gst.State.PLAYING) {
                media_playing();
            }
            else if (new_state == Gst.State.PAUSED) {
                media_paused();
            }
            
            break;
        /*case MessageType.TAG:
            
            string str;
                
            Gst.TagList tag;
            message.parse_tag (out tag);
            tag.get_string ("title", out title);
                       
            //var str = tag.to_string ();
            
            //stdout.printf ("\nTitle is: %s\n", title);
            //stdout.printf ("\nAll tags are: %s\n", str);
            
            break;*/
        case MessageType.STREAM_START:
            this.media_changed ();
            this.media_duration_changed(this.get_song_duration());
            break;
        case MessageType.DURATION_CHANGED:
            //this.media_duration_changed(this.get_song_duration());
            break;
        case MessageType.ANY:
            this.media_position_changed (this.get_song_position());
        break;
        default:
            break;
        }
       
        return true;
    }

    public void set_media_file (string uri) {
        this.media_uri = uri;
    }

    public void play () {
        playbin.uri = media_uri;
        playbin.set_state (State.PLAYING);
    }

    public void pause () {
        playbin.set_state(Gst.State.PAUSED);
        
    }

    public void stop () {
        playbin.set_state (Gst.State.NULL);
    }
    
    public Gst.State get_state () {
    
        Gst.State state;
        Gst.State pending;
    
        playbin.get_state (out state, out pending, 5 * Gst.SECOND);
        
        return state;
    }
    
    public bool is_playing () {
        if (this.get_state() == Gst.State.PLAYING) {
            return true;
        }
        
        return false;
    }
    
    public void set_state (Gst.State state) {
        playbin.set_state (state);
    }
    
    public int64 get_song_position () {
        Gst.Format format = Gst.Format.TIME;
        
        int64 pos;
        
        playbin.query_position (format, out pos);
        
		return pos;
    }
    
    public int64 get_song_duration () {
        Gst.Format format = Gst.Format.TIME;
        
        int64 dur;
        
        playbin.query_duration (format, out dur);
        
        stdout.printf ("\nDuration %" + int64.FORMAT + "\n",
		                  dur);
        
        return dur;
    }
    
    public void seek (int64 seek_pos) {
        playbin.seek_simple (Gst.Format.TIME, Gst.SeekFlags.FLUSH, seek_pos);
    }
    
    public string get_current_uri () {
        return this.media_uri;
    }
}

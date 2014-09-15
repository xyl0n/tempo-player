public class Tempo.AlbumObject {
    
    public string title;
    public string song_count;
    public string artist;
    
    public Gtk.Image album_art;
    public Gdk.Pixbuf album_pix;
    
    private MediaObject[] song_list;
    
    public AlbumObject() {
    
        Gtk.IconTheme theme = Gtk.IconTheme.get_default ();
        Gtk.IconInfo info = theme.lookup_icon ("folder-music-symbolic", 128,
                                               Gtk.IconLookupFlags.FORCE_SVG);
        
        var temp_pix = info.load_icon ();
    
        album_pix = this.make_frame (temp_pix);
    
        album_art = new Gtk.Image.from_pixbuf (album_pix);
    
        song_list = { };
    }
    
    public void add_song_to_album (MediaObject song) {
        this.song_list += song;
    }
    
    public MediaObject? get_song_at_number (int num) { //Add function get song at num, rename this to get_song_at_track_number
        num++;
                
        for (int i = 0; i < song_list.length; i++) {
            if (song_list[i].track_num == num) {
                return song_list[i];
            }
        }
        
        return null;
    } 
    
    public int get_song_count () {
        return song_list.length;
    }
    
    public void load_album_art (File art_image) {
        album_art.set_from_file (art_image.get_uri());
    }
    
    public Gdk.Pixbuf? make_frame (Gdk.Pixbuf pixbuf) {
        var border = 2;
        var degrees = 3.14 / 180; //Use some actual value of pi in future
        var radius = 3;
        
        int w = pixbuf.get_width ();
        int h = pixbuf.get_height ();
        
        var new_pix = pixbuf.scale_simple ( w - border * 2,
                                            h - border * 2, 0);
                                           
        var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, w, h);
        var ctx = new Cairo.Context (surface);
        ctx.new_sub_path ();
        ctx.arc(w - radius, radius, radius - 0.5, -90 * degrees, 0 * degrees);
        ctx.arc(w - radius, h - radius, radius - 0.5, 0 * degrees, 90 * degrees);
        ctx.arc(radius, h - radius, radius - 0.5, 90 * degrees, 180 * degrees);
        ctx.arc(radius, radius, radius - 0.5, 180 * degrees, 270 * degrees);
        ctx.close_path();
        ctx.set_line_width(0.6);
        ctx.set_source_rgb(0.2, 0.2, 0.2);
        ctx.stroke_preserve();
        ctx.set_source_rgb(1, 1, 1);
        ctx.fill();
        var border_pixbuf = Gdk.pixbuf_get_from_surface(surface, 0, 0, w, h);

        new_pix.copy_area(border, border,
                          w - border * 4,
                          h - border * 4,
                          border_pixbuf,
                          border * 2, border * 2);
        
        return border_pixbuf;     
        
    }
    
}

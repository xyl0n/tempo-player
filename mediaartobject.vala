/*public class Tempo.MediaArtObject {
    
    public Gtk.Image art_img;
    public Gdk.Pixbuf? art_pix;
    
    public string uri;
    public string art_dir;
        
    public MediaArtObject (string media_name) {
        var cache_dir = Environment.get_user_cache_dir ();      
        art_dir = cache_dir + "/tempo/media-art/";   
        
        uri = art_dir + generate_image_key (media_name); 
        
        art_img = new Gtk.Image ();
        art_pix = null;    
    }
    
    public void load_image () {
        try {
            // Try to load the album art image
            var temp_pix = new Gdk.Pixbuf.from_file_at_scale (uri, 128, 128, true);
            art_pix = temp_pix;
        } catch (Error e) {
            // If it fails, use a default image
            stderr.printf ("ERROR %d: %s\n", e.code, e.message);
            Gtk.IconTheme theme = Gtk.IconTheme.get_default ();
            Gtk.IconInfo info = theme.lookup_icon ("folder-music-symbolic", 128,
                                                   Gtk.IconLookupFlags.FORCE_SVG);
            art_pix = info.load_icon();
        }
        art_pix = make_frame (art_pix);
        
        art_img.set_from_pixbuf (art_pix);
    }
    
    public string generate_image_key (string text) {
        return GLib.Checksum.compute_for_string(ChecksumType.MD5, text, text.length);
    }    

    // Copied some Gnome Music code, sorry :P    
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
*/

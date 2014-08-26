/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * main.c
 * Copyright (C) 2014 Aporva Varshney <avlabs314@gmail.com>
 * 
 * MusicPlayer is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * MusicPlayer is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;
using Gtk;

public class Tempo.Main : Object {
    private Interface window_ui;
    private StreamPlayer player;

    private MusicManager manager;
    
    public LastFm last_fm;
          
    public Main ()
    {        
        Window window = new Window();
        
        window_ui = new Interface(window);
        
        manager = new MusicManager();  
                                               
        window.set_title ("Music");
        window.set_default_size (1200, 800);

        var screen = Gdk.Screen.get_default();
        
        var css = new Gtk.CssProvider();
        css.load_from_path ("application.css");
        
        var context = new Gtk.StyleContext ();
        context.add_provider_for_screen (screen, css, Gtk.STYLE_PROVIDER_PRIORITY_USER);

        window.show_all();
                
        window.destroy.connect(on_destroy);
    }

    public void on_destroy (Widget window) {
        Gtk.main_quit();
        //player.stop();
        //window_ui.app_running = false;
    }
    
    static int main (string[] args) {
        Gtk.init (ref args);
        Gst.init (ref args);
        
        var app = new Main ();

        //while (app.is_running) {
        //app.last_fm = new LastFm();
        //Gdk.Pixbuf? img = app.last_fm.download_cover_art 
        //    (app.last_fm.get_art_uri ("Green+Day", "American+Idiot"));
        Gtk.main ();
            
        //execute in new thread*/      
            
        //    app.update_all ();
        //}
		
        return 0;
    }
}

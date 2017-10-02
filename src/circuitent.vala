/* -*- Mode: C; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*-  */
/*
 * main.c
 * Copyright (C) 2017 Ben Foote <ben.foote@gmail.com>
     *
 * Circuitent is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
     *
 * Circuitent is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using GLib;
using Gtk;

public class CircuitentDrawingSurface : DrawingArea
{
     private bool dragging;
     private double mouseX;
     private double mouseY;
     private double[] circlesX = {};
     private double[] circlesY = {};

     private double iZoomFactor = 1;

     private Kicad_sch sch;

     public CircuitentDrawingSurface ()
     {
         add_events (Gdk.EventMask.BUTTON_PRESS_MASK
                     | Gdk.EventMask.SCROLL_MASK
                     | Gdk.EventMask.BUTTON_RELEASE_MASK
                     | Gdk.EventMask.POINTER_MOTION_MASK);

         sch = new Kicad_sch("BT-DMG.sch");
     }

     public void DrawWires(Cairo.Context cr)
     {
         //cr.save ();

         foreach(Wire w in sch.Wires)
         {
             cr.set_source_rgb (0, 0, 0);
             cr.set_line_width(1);
             cr.move_to (w.StartX/10, w.StartY/10);
             cr.line_to (w.EndX/10, w.EndY/10);
             cr.stroke ();
             //cr.close_path ();
         }
         //cr.restore ();
     }

     public void DrawComponents(Cairo.Context cr)
     {
         foreach (Component c in sch.Components)
         {
             cr.set_source_rgb (1, 0, 0);
             cr.set_line_width(1);
             cr.rectangle (c.PositionX/10, c.PositionY/10, 25, 25);
             cr.stroke ();

             cr.select_font_face("Arial", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
             cr.set_font_size(12);
             cr.move_to ((c.PositionX/10) + 30, (c.PositionY/10) + 30);
             cr.show_text (c.Name);
         }
     }

     public void DrawNoConnects(Cairo.Context cr)
     {
         foreach (NoConnect nc in sch.NoConnects)
         {
             cr.set_source_rgb (0, 0, 0);
             cr.set_line_width(1);
             cr.move_to ((nc.X/10) - 5, (nc.Y/10) - 5);
             cr.line_to ((nc.X/10) + 5, (nc.Y/10) + 5);
             cr.move_to ((nc.X/10) + 5, (nc.Y/10) - 5);
             cr.line_to ((nc.X/10) - 5, (nc.Y/10) + 5);
             cr.stroke ();
         }
     }

     public override bool draw (Cairo.Context cr)
     {
         cr.translate(mouseX, mouseY);
         cr.scale(iZoomFactor, iZoomFactor);
         cr.translate(-mouseX, -mouseY);

         for(int i = 0; i < circlesX.length; i++)
         {
             cr.save ();
             //cr.set_line_width(iZoomFactor);
             cr.new_path();
             //cr.arc (circlesX[i] * iZoomFactor, circlesY[i] * iZoomFactor, 5 * iZoomFactor, 0, 2 * Math.PI);
             cr.arc (circlesX[i], circlesY[i], 5, 0, 2 * Math.PI);
             cr.set_source_rgb (1, 1, 1);
             cr.fill_preserve ();
             cr.set_source_rgb (0, 0, 0);
             cr.stroke ();
             cr.close_path ();
             cr.restore ();
         }

         DrawWires (cr);
         DrawComponents (cr);
         DrawNoConnects (cr);

         return false;
     }

     public override bool scroll_event(Gdk.EventScroll event)
     {
         stdout.printf("Scrolled, x = %d\n", event.direction);

         if(event.direction == 0)
             iZoomFactor += 0.1;

         if((event.direction == 1) && (iZoomFactor > 0.1))
             iZoomFactor -= 0.1;

         mouseX = event.x;
         mouseY = event.y;

         redraw_canvas ();

         return false;
     }

     public override bool button_press_event (Gdk.EventButton event)
     {
         mouseX = event.x;
         mouseY = event.y;

         stdout.printf("Drawing Area clicked, x = %f, y = %f\n", mouseX, mouseY);

         circlesX += mouseX;
         circlesY += mouseY;

         /*
         var minutes = this.time.minute + this.minute_offset;

         // From
         // http://mathworld.wolfram.com/Point-LineDistance2-Dimensional.html
         var px = event.x - get_allocated_width () / 2;
         var py = get_allocated_height () / 2 - event.y;
         var lx = Math.sin (Math.PI / 30 * minutes);
         var ly = Math.cos (Math.PI / 30 * minutes);
         var u = lx * px + ly * py;

         // on opposite side of origin
         if (u < 0) {
             return false;
         }

         var d2 = Math.pow (px - u * lx, 2) + Math.pow (py - u * ly, 2);

         if (d2 < 25) {      // 5 pixels away from the line
             this.dragging = true;
             print ("got minute hand\n");
         }
         */
         return false;
     }

     public override bool button_release_event (Gdk.EventButton event)
     {
         stdout.printf("Drawing Area un-clicked!\n");

         redraw_canvas ();

         /*
         if (this.dragging)
         {
             this.dragging = false;
             emit_time_changed_signal ((int) event.x, (int) event.y);
         }
         */
         return false;
     }

     public override bool motion_notify_event (Gdk.EventMotion event)
     {
         stdout.printf("Drawing Area motion: %f, %f\n", event.x, event.y);
         /*
         if (this.dragging)
         {
             emit_time_changed_signal ((int) event.x, (int) event.y);
         }
         */
         return false;
     }

     private void redraw_canvas ()
     {
         var window = get_window ();
         if (null == window) {
             return;
         }

         var region = window.get_clip_region ();
         // redraw the cairo canvas completely by exposing it
         window.invalidate_region (region, true);
         window.process_updates (true);
     }
 }

/*
public class MainWindow : Gtk.Window
{
    public MainWindow(Gtk.Application application)
    {
        Object
        (
            application: application,
            height_request: 500,
            icon_name: "com.github.benpocalypse.circuitent",
            resizable: true,
            title: _("Circuitent"),
            width_request: 700
        );
    }
}
*/

public class Main : Gtk.Application
{
    int iButtonMode = 0;

     public Main ()
     {
        Object(application_id: "com.github.benpocalypse.circuitent",
             flags: ApplicationFlags.FLAGS_NONE);
     }

     protected override void activate ()
     {
         // create the window of this application and show it
         Gtk.ApplicationWindow window = new Gtk.ApplicationWindow (this);
         window.set_default_size (800, 600);
         //window.icon = new Gdk.Pixbuf.from_file ("data/images/icon-128.png");
         //window.icon = IconTheme.get_default ().load_icon ("go-home", 128, 0);
         //var icon = new Gtk.Image.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.DND);
         //window.icon = icon.get_pixbuf ();
         window.set_border_width (12);

         // add headerbar with button
         Gtk.HeaderBar headerbar = new Gtk.HeaderBar();
         headerbar.show_close_button = true;
         headerbar.title = "Circuitent";
         window.set_titlebar (headerbar);

         Gtk.Button button1 = new Gtk.Button.with_label ("S");
         button1.clicked.connect (() =>
                                  {
             iButtonMode = 1;
         });
         button1.clicked.connect (button_clicked);


         /*
         button1.clicked.connect (() =>
                                  {

             // show about dialog on click
             string[] authors = { "GNOME Documentation Team", null };
             string[] documenters = { "GNOME Documentation Team", null };

             Gtk.show_about_dialog (window,
                                    "program-name", ("GtkApplication Example"),
                                    "copyright", ("Copyright \xc2\xa9 2012 GNOME Documentation Team"),
                                    "authors", authors,
                                    "documenters", documenters,
                                    "website", "http://developer.gnome.org",
                                    "website-label", ("GNOME Developer Website"),
                                    null);
         });
         */

         // add button to headerbar
         headerbar.pack_start (button1);

         CircuitentDrawingSurface da = new CircuitentDrawingSurface();
         window.add (da);

         /*
         // create stack
         Gtk.Stack stack = new Gtk.Stack ();
         stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);

         // giving widgets to stack
         Gtk.Label label = new Gtk.Label ("A label");
         stack.add_titled (label, "label", "A label");

         Gtk.Label label2 = new Gtk.Label ("Another label");
         stack.add_titled (label2, "label2", "Another label");

         // add stack (contains widgets) to stackswitcher widget
         Gtk.StackSwitcher stack_switcher = new Gtk.StackSwitcher ();
         stack_switcher.halign = Gtk.Align.CENTER;
         stack_switcher.set_stack (stack);

         // add stackswitcher to vertical box
         Gtk.Box vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
         vbox.pack_start (stack_switcher, false, false, 0);
         vbox.pack_start (stack, false, false, 10);

         window.add (vbox);
         */

         window.show_all ();
     }

     public void button_clicked(Gtk.Button button_clicked)
     {
         stdout.printf("Clicked! = %d\n", iButtonMode);
     }

     public void on_destroy (Widget window)
     {
         Gtk.main_quit();
     }

     static int main (string[] args)
     {
         Main app = new Main ();
         //Kicad_sch sch = new Kicad_sch("BT-DMG.sch");
         //sch.Print ();
         return app.run (args);
     }
 }


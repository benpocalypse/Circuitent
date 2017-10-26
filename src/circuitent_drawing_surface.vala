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

namespace com.github.benpocalypse.circuitent
{
    public class CircuitentDrawingSurface : DrawingArea
    {
        private bool dragging;
        private double mouseX;
        private double mouseY;

        private double iZoomFactor = 1;
        private const int Width = 1027;
        private const int Height = 768;

        public signal void LeftButtonClicked (double x, double y);
        public signal void RightButtonClicked (double x, double y);

        public CircuitentDrawingSurface ()
        {
            add_events (Gdk.EventMask.BUTTON_PRESS_MASK
                        | Gdk.EventMask.SCROLL_MASK
                        | Gdk.EventMask.BUTTON_RELEASE_MASK
                        | Gdk.EventMask.POINTER_MOTION_MASK);

            this.width_request = Width;
            this.height_request = Height;

            stdout.printf("Width: %f, Height: %f\n", this.get_allocated_width (),
                           this.get_allocated_height ());
        }


         public void ResetZoom ()
         {
            iZoomFactor = 1;
            mouseY = 0;
            mouseX = 0;

            this.width_request = Width;
            this.height_request = Height;

            redraw_canvas ();
         }


         public void DrawWires(Cairo.Context cr)
         {
            /*
             foreach(WireSegment w in sch.Wires)
             {
                 cr.set_source_rgb (0, 0, 0);
                 cr.set_line_width(1);
                 cr.move_to (w.StartX/10, w.StartY/10);
                 cr.line_to (w.EndX/10, w.EndY/10);
                 cr.stroke ();
             }
             */
         }


         public void DrawComponents(Cairo.Context cr)
         {
            /*
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
             */
         }


         public void DrawNoConnects(Cairo.Context cr)
         {
         /*
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
             */
         }


         public override bool draw (Cairo.Context cr)
         {
            //stdout.printf("Width: %f, Height: %f\n", this.get_allocated_width (),
            //                this.get_allocated_height ());

/*
             // FIXME - figure out how/why this doesn't work
             stdout.printf("Mouse X: %f, Mouse Y :%f, iZoomFactor: %f\n",
                            mouseX, mouseY, iZoomFactor);

             cr.translate(mouseX, mouseY);
             cr.scale(iZoomFactor, iZoomFactor);
             cr.translate(-(mouseX), -(mouseY));

             // First draw circles (this is just a debug thing to track drawing operations)
             for(int i = 0; i < circlesX.length; i++)
             {
                 cr.save ();

                 //cr.set_line_width(iZoomFactor);

                 cr.new_path();
                 cr.arc (circlesX[i], circlesY[i], 5, 0, 2 * Math.PI);
                 cr.set_source_rgb (1, 1, 1);
                 cr.fill_preserve ();
                 cr.set_source_rgb (0, 0, 0);
                 cr.stroke ();
                 cr.close_path ();
                 cr.restore ();
             }

             // FIXME - might want to remove this to make it appear more 'vectory'
             cr.set_line_width(iZoomFactor);

             DrawWires (cr);
             DrawComponents (cr);
             DrawNoConnects (cr);
*/
             return true;
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

             this.width_request = (int)(iZoomFactor * (float)Width);
             this.height_request = (int)(iZoomFactor * (float)Height);

             redraw_canvas ();

             return false;
         }


         public override bool button_press_event (Gdk.EventButton event)
         {
             stdout.printf("Drawing Area clicked, x = %f, y = %f\n", event.x, event.y);

             //circlesX += (event.x);
             //circlesY += (event.y);

             return false;
         }


         public override bool button_release_event (Gdk.EventButton event)
         {
             stdout.printf("Drawing Area un-clicked: %u\n", event.button);

            if (event.button == 1)
            {
                LeftButtonClicked (event.x, event.y);
            }

            if (event.button == 3)
            {
                RightButtonClicked (event.x, event.y);
            }

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
             //stdout.printf("Drawing Area motion: %f, %f\n", event.x, event.y);

             //mouseX = event.x;
             //mouseY = event.y;

            // No reason to do this here when the mouse moves.
            // redraw_canvas ();

             return false;
         }


        private void redraw_canvas ()
        {
            var window = get_window ();

            if (null == window)
            {
                return;
            }

            var region = window.get_clip_region ();

            // redraw the cairo canvas completely by exposing it
            window.invalidate_region (region, true);
            window.process_updates (true);
        }
    }
}


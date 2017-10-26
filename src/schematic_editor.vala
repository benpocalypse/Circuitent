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
    public class SchematicEditor : Gtk.Viewport, IEditor
    {
        private CircuitentDrawingSurface dsSchematic = new CircuitentDrawingSurface();

        public Kicad_sch sch;

        public SchematicEditor ()
        {
            Gtk.Paned pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            //pane.set_orientation (Gtk.Orientation.HORIZONTAL);

            Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);
            //scrolled.set_size_request (400, 400);
            //scrolled.set_policy (PolicyType.ALWAYS, PolicyType.ALWAYS);

            Gtk.Viewport view = new Gtk.Viewport (null, null);
            view.add (dsSchematic);
            //view.set_size_request (400, 400);
            scrolled.add (view);

            //this.pack1 (view, true, true);
            pane.pack1 (scrolled, true, true);
            pane.set_border_width (0);

            dsSchematic.LeftButtonClicked.connect (LeftButtonClicked);
            dsSchematic.RightButtonClicked.connect (RightButtonClicked);

            //Gtk.Box commandBox = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);

            Gtk.FlowBox commandBox = new Gtk.FlowBox ();
            commandBox.width_request = 32;
            commandBox.height_request = 32;
            commandBox.valign = Gtk.Align.START;
            commandBox.homogeneous = false;
            commandBox.row_spacing = 0;
            commandBox.column_spacing = 0;
            commandBox.set_border_width (0);
    //            commandBox.set_shadow_type (Gtk.ShadowType.NONE);
            pane.pack2 (commandBox, false, false);

            Gtk.ToggleButton buttonSelect = new Gtk.ToggleButton ();
            Gtk.Image imgButtonSelect = new Gtk.Image.from_file ("com.github.benpocalypse.pointer_select.png");
            buttonSelect.set_image (imgButtonSelect);
            buttonSelect.width_request = 32;
            buttonSelect.height_request = 32;
            buttonSelect.valign = Gtk.Align.START;
            commandBox.insert (buttonSelect, 0);

            Gtk.ToggleButton buttonComponent = new Gtk.ToggleButton ();
            Gtk.Image imgButtonComponent = new Gtk.Image.from_file ("com.github.benpocalypse.place_component.png");
            buttonComponent.set_image (imgButtonComponent);
            buttonComponent.width_request = 32;
            buttonComponent.height_request = 32;
            buttonComponent.valign = Gtk.Align.START;
            commandBox.insert (buttonComponent, 1);

            Gtk.ToggleButton buttonDrawWire = new Gtk.ToggleButton ();
            Gtk.Image imgButtonDrawWire = new Gtk.Image.from_file ("com.github.benpocalypse.draw_wire.png");
            buttonDrawWire.set_image (imgButtonDrawWire);
            buttonDrawWire.width_request = 32;
            buttonDrawWire.height_request = 32;
            buttonDrawWire.valign = Gtk.Align.START;
            commandBox.insert (buttonDrawWire, 2);

            Gtk.ToggleButton buttonDrawNoConnect = new Gtk.ToggleButton ();
            Gtk.Image imgButtonDrawNoconnect = new Gtk.Image.from_file ("com.github.benpocalypse.draw_no_connect.png");
            buttonDrawNoConnect.set_image (imgButtonDrawNoconnect);
            buttonDrawNoConnect.width_request = 32;
            buttonDrawNoConnect.height_request = 32;
            buttonDrawNoConnect.valign = Gtk.Align.START;
            commandBox.insert (buttonDrawNoConnect, 3);

            Gtk.ToggleButton buttonDrawLocalNet = new Gtk.ToggleButton ();
            Gtk.Image imgButtonDrawLocalNet = new Gtk.Image.from_file ("com.github.benpocalypse.draw_local_net.png");
            buttonDrawLocalNet.set_image (imgButtonDrawLocalNet);
            buttonDrawLocalNet.width_request = 32;
            buttonDrawLocalNet.height_request = 32;
            buttonDrawLocalNet.valign = Gtk.Align.START;
            commandBox.insert (buttonDrawLocalNet, 4);

            Gtk.ToggleButton buttonDrawGlobalNet = new Gtk.ToggleButton ();
            Gtk.Image imgButtonDrawGlobalNet = new Gtk.Image.from_file ("com.github.benpocalypse.draw_global_net.png");
            buttonDrawGlobalNet.set_image (imgButtonDrawGlobalNet);
            buttonDrawGlobalNet.width_request = 32;
            buttonDrawGlobalNet.height_request = 32;
            buttonDrawGlobalNet.valign = Gtk.Align.START;
            commandBox.insert (buttonDrawGlobalNet, 5);

            Gtk.ToggleButton buttonDrawText = new Gtk.ToggleButton ();
            Gtk.Image imgButtonDrawText = new Gtk.Image.from_file ("com.github.benpocalypse.draw_text.png");
            buttonDrawText.set_image (imgButtonDrawText);
            buttonDrawText.width_request = 32;
            buttonDrawText.height_request = 32;
            buttonDrawText.valign = Gtk.Align.START;
            commandBox.insert (buttonDrawText, 6);

            this.add (pane);

            this.show_all ();
        }

        public void LeftButtonClicked (CircuitentDrawingSurface sender, double x, double y)
        {
            stdout.printf ("Left Button Clicked: %f, %f\n", x, y);
        }

        public void RightButtonClicked (CircuitentDrawingSurface sender, double x, double y)
        {
            stdout.printf ("Right Button Clicked: %f, %f\n", x, y);
        }

        public void Open (string filename)
        {
            sch = new Kicad_sch (filename);
        }

        public void ResetZoom ()
        {
            dsSchematic.ResetZoom ();
        }
    }
}


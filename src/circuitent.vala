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
    public class MainWindow : Gtk.Window
    {
        int iButtonMode = 0;

        public MainWindow(Gtk.Application application)
        {
            Object
            (
                application: application,
                height_request: 480,
                icon_name: "com.github.benpocalypse.circuitent",
                resizable: true,
                title: _("Circuitent"),
                width_request: 640
            );
        }

        construct
        {
            this.set_border_width (12);

            CircuitentDrawingSurface dsSchematic = new CircuitentDrawingSurface();

            // add headerbar with button
            Gtk.HeaderBar headerbar = new Gtk.HeaderBar();
            headerbar.show_close_button = true;
            //headerbar.title = "Circuitent";
            this.set_titlebar (headerbar);

            Gtk.Button button1 = new Gtk.Button.with_label ("S");
            button1.clicked.connect (() =>
            {
                iButtonMode = 1;
            });
            button1.clicked.connect (button_clicked);

            Gtk.Button button_reset_zoom = new Gtk.Button.with_label ("Z");
            button_reset_zoom.clicked.connect (() =>
            {
                dsSchematic.ResetZoom();
            });

            var open_icon = new Gtk.Image.from_icon_name ("document-open",
                                                          IconSize.SMALL_TOOLBAR);
            var open_button = new Gtk.ToolButton (open_icon, "Open");
            open_button.is_important = true;
            headerbar.pack_start (open_button);
            open_button.clicked.connect (() =>
            {
                var file_chooser = new FileChooserDialog ("Open Schematic", this,
                                              FileChooserAction.OPEN,
                                              "_Cancel", ResponseType.CANCEL,
                                              "_Open", ResponseType.ACCEPT);

                Gtk.FileFilter filter = new Gtk.FileFilter ();
                filter.set_filter_name ("Schematics");
                filter.add_pattern ("*.sch");
                file_chooser.add_filter (filter);

                if (file_chooser.run () == ResponseType.ACCEPT)
                {
                    dsSchematic.Open(file_chooser.get_filename ());
                    //da.sch.Print ();
                }
                file_chooser.destroy ();
            });

            // add button to headerbar
            headerbar.pack_end (button1);
            headerbar.pack_end (button_reset_zoom);

            this.set_icon_name ("com.github.benpocalypse.circuitent");
            this.set_default_icon_name ("com.github.benpocalypse.circuitent");

            stdout.printf("this.icon_name = %s\n", this.icon_name);

            Gtk.Stack stack = new Gtk.Stack ();

/*
            Gtk.ScrolledWindow scrolled = new Gtk.ScrolledWindow (null, null);
            Gtk.Viewport viewport = new Gtk.Viewport (null, null);
            scrolled.set_shadow_type (Gtk.ShadowType.NONE);
            scrolled.add (viewport);
            viewport.add (da);
            viewport.set_shadow_type (Gtk.ShadowType.NONE);
*/
            Gtk.Paned paneSchematic = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paneSchematic.pack1 (dsSchematic, true, true);
//            paneSchematic.pack1 (scrolled, true, true);
            paneSchematic.set_border_width (0);

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
            paneSchematic.pack2 (commandBox, false, false);

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

            //Gtk.Paned paneLibrary = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            paneSchematic.pack1 (dsSchematic, true, true);
//            paneSchematic.pack1 (scrolled, true, true);
            paneSchematic.set_border_width (0);

            stack.add_titled (paneSchematic, "Schematic", "Schematic");
            stack.add_titled (new LibraryEditor(), "Library", "Library");
            stack.add_titled (new CircuitentDrawingSurface (), "Component", "Component");
            stack.add_titled (new CircuitentDrawingSurface (), "Footprint", "Footprint");
            stack.add_titled (new CircuitentDrawingSurface (), "Layout", "Layout");
            stack.set_transition_type (Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            stack.set_valign (Gtk.Align.FILL);
            stack.set_border_width (0);

            Gtk.StackSwitcher switcher = new Gtk.StackSwitcher();
            switcher.margin_bottom = 12;
            switcher.set_halign (Gtk.Align.CENTER);
            switcher.set_valign (Gtk.Align.START);
            switcher.set_stack (stack);
            switcher.set_border_width (0);


            Gtk.Paned pane = new Gtk.Paned (Gtk.Orientation.VERTICAL);
            pane.set_border_width (0);
            pane.add1 (switcher);
            pane.add2 (stack);

            this.add (pane);

            this.show_all ();
        }

        public void button_clicked(Gtk.Button button_clicked)
        {
            stdout.printf("Clicked! = %d\n", iButtonMode);
        }

        public void on_destroy (Widget window)
        {
            Gtk.main_quit();
        }
    }


    public class Main : Gtk.Application
    {
        public Main ()
        {
            Object(application_id: "com.github.benpocalypse.circuitent",
                   flags: ApplicationFlags.FLAGS_NONE);
        }

        protected override void activate ()
        {
            MainWindow app_window = new MainWindow (this);

            app_window.show_all ();

            var quit_action = new SimpleAction ("quit", null);

            add_action (quit_action);
            add_accelerator ("<Control>q", "app.quit", null);

            quit_action.activate.connect (() =>
            {
                if (app_window != null)
                {
                    app_window.destroy ();
                }
            });
        }


        static int main (string[] args)
        {
            Main app = new Main ();
            //Kicad_sch sch = new Kicad_sch("BT-DMG.sch");
            //sch.Print ();
            return app.run (args);
        }
     }
}

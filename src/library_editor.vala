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
    public class LibraryEditor : Gtk.Paned
    {
        private CircuitentDrawingSurface dsLibrary;
        //private Gtk.Paned paneLibrary;
        private Gtk.TreeView viewLibraries;
        private Gtk.TreeStore storeLibraries;

        public LibraryEditor ()
        {
            this.set_orientation (Gtk.Orientation.HORIZONTAL);
            dsLibrary = new CircuitentDrawingSurface();
            //paneLibrary = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            viewLibraries = new Gtk.TreeView ();
            storeLibraries = new Gtk.TreeStore (5, typeof (string),
                                                   typeof (string),
                                                   typeof (string),
                                                   typeof (string),
                                                   typeof (string));

            viewLibraries.set_model (storeLibraries);

            viewLibraries.insert_column_with_attributes (-1, "Name", new CellRendererText (), "text", 0, null);
            viewLibraries.insert_column_with_attributes (-1, "Reference", new CellRendererText (), "text", 1, null);
            viewLibraries.insert_column_with_attributes (-1, "Footprint", new CellRendererText (), "text", 2, null);
            viewLibraries.insert_column_with_attributes (-1, "Datasheet", new CellRendererText (), "text", 3, null);
            viewLibraries.insert_column_with_attributes (-1, "PartNumber", new CellRendererText (), "text", 4, null);

            Gtk.TreeIter root;
            Gtk.TreeIter product_iter;

            storeLibraries.append (out root, null);
            storeLibraries.set (root, 0, "All Components", -1);

            storeLibraries.append (out product_iter, root);
            storeLibraries.set (product_iter, 0, "Dual MosFET",
                                              1, "U1",
                                              2, "SOIC-4",
                                              3, "N/A",
                                              4, "IXF4831",
                                              -1);
            storeLibraries.append (out product_iter, root);
            storeLibraries.set (product_iter, 0, "Dual MosFET",
                                                          1, "U1",
                                                          2, "SOIC-4",
                                                          3, "N/A",
                                                          4, "IXF4831",
                                                          -1);

            viewLibraries.expand_all ();
            this.pack1 (viewLibraries, true, true);
            this.pack2 (dsLibrary, true, true);
            this.set_border_width (0);
        }
    }
}


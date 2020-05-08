/*
 * Copyright (c) 2011-2017 elementary LLC (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */

public class Wingpanel.Widgets.Container : Gtk.Bin {
    public signal void clicked ();

    public Gtk.Grid content_widget { owned get; construct; }

    public extern Gtk.Grid get_content_widget ();

    public Container () {}

    construct {
        content_widget = new Gtk.Grid ();
        content_widget.hexpand = true;

        var modelbutton = new Gtk.ModelButton ();
        modelbutton.get_child ().destroy ();
        modelbutton.add (content_widget);

        add (modelbutton);

        modelbutton.button_release_event.connect (() => {
            clicked ();
            // Stop modelbutton from closing the popover
            return Gdk.EVENT_STOP;
        });
    }
}

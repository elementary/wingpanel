/*
 * Copyright 2011-2020 elementary, Inc. (https://elementary.io)
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

public class Wingpanel.Widgets.IndicatorPopover : Gtk.Popover {
    private unowned Gtk.Widget? widget = null;

    private Gtk.Box container;

    construct {
        width_request = 256;
        // TODO: See if we need the autohide behaviour here
        // modal = false;
        name = name + "/popover";
        position = Gtk.PositionType.BOTTOM;

        container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            margin_top = 3,
            margin_bottom = 3
        };

        child = container;
    }

    public void set_content (Gtk.Widget? content) {
        if (content == widget) {
            return;
        }

        if (widget != null) {
            container.remove (widget);
            widget = null;
        }

        if (content != null) {
            container.append (content);
            widget = content;
        }
    }
}

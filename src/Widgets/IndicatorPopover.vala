/*
 * Copyright (c) 2011-2015 Wingpanel Developers (http://launchpad.net/wingpanel)
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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class Wingpanel.Widgets.IndicatorPopover : Gtk.Popover {
    private unowned Gtk.Widget? widget = null;

    private Gtk.Box container;

    public IndicatorPopover () {
        this.set_size_request (256, -1);
        this.name = name + "/popover";
        modal = false;

        position = Gtk.PositionType.BOTTOM;
        container = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        container.margin_top = 3;
        container.margin_bottom = 3;

        this.add (container);
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
            container.add (content);
            widget = content;
        }
    }
}

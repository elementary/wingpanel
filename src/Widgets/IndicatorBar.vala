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
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */

public class Wingpanel.Widgets.IndicatorBar : Granite.Bin {
    public ListModel indicator_entries { private get; construct; }

    private Gtk.FlowBox flow_box;

    public IndicatorBar (ListModel indicator_entries) {
        Object (indicator_entries: indicator_entries);
    }

    construct {
        flow_box = new Gtk.FlowBox () {
            orientation = HORIZONTAL,
            selection_mode = NONE
        };
        flow_box.bind_model (indicator_entries, (indicator_entry) => (IndicatorEntry) indicator_entry);

        indicator_entries.items_changed.connect (update_flow_box_max_children);

        child = flow_box;
    }

    private void update_flow_box_max_children () {
        flow_box.max_children_per_line = indicator_entries.get_n_items ();
    }
}

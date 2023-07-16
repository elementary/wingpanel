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

public class Wingpanel.Widgets.IndicatorMenuBar : Gtk.MenuBar {
    private Gee.List<IndicatorEntry> sorted_items;
    private Gee.List<IndicatorEntry> sorted_visible_items;
    private Services.IndicatorSorter sorter = new Services.IndicatorSorter ();

    construct {
        sorted_items = new Gee.ArrayList<IndicatorEntry> ();
        sorted_visible_items = new Gee.ArrayList<IndicatorEntry> ();
    }

    public void insert_sorted (IndicatorEntry item) {
        item.menu_bar = this;

        if (!(item in sorted_items)) {
            sorted_items.add (item);
            sorted_items.sort (sorter.compare_func);
        }

        // sorted_visible_items tracks visible indicators
        // because we can't rely on sorted_items.index_of to get indicator index
        // because some indicators can be hidden and then sorted_items.index_of will be shifted
        if (item.base_indicator.visible) {
            if (!(item in sorted_visible_items)) {
                sorted_visible_items.add (item);
                sorted_visible_items.sort (sorter.compare_func);
            }
            this.insert (item, sorted_visible_items.index_of (item));
        }
    }

    public override void remove (Gtk.Widget widget) {
        var indicator_widget = widget as IndicatorEntry;

        if (indicator_widget != null) {
            sorted_items.remove (indicator_widget);
            sorted_visible_items.remove (indicator_widget);
        }
        
        base.remove (widget);
    }
}

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
    private Services.IndicatorSorter sorter = new Services.IndicatorSorter ();

    construct {
        sorted_items = new Gee.ArrayList<IndicatorEntry> ();
    }

    public void insert_sorted (IndicatorEntry item) {
        item.menu_bar = this;

        if (!(item in sorted_items)) {
            sorted_items.add (item);
            sorted_items.sort (sorter.compare_func);
        }

        if (item.base_indicator.visible) {
            var index = 0;
            foreach (var i in sorted_items) {
                if (i == item) {
                    break;
                }

                if (item.base_indicator.visible) {
                    index++;
                }
            }

            this.insert (item, index);
        }
    }

    public override void remove (Gtk.Widget widget) {
        var indicator_widget = widget as IndicatorEntry;

        if (indicator_widget != null) {
            sorted_items.remove (indicator_widget);
        }

        base.remove (widget);
    }
}

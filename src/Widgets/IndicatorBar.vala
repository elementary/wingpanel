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

public class Wingpanel.Widgets.IndicatorBar : Gtk.Box {
    private Gee.List<IndicatorEntry> sorted_items;
    private Services.IndicatorSorter sorter = new Services.IndicatorSorter ();

    construct {
        sorted_items = new Gee.ArrayList<IndicatorEntry> ();

        spacing = 6;
    }

    public void insert_sorted (IndicatorEntry item) {
        item.indicator_bar = this;

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

                if (i.base_indicator.visible) {
                    index++;
                }
            }

            if (item.get_parent () != this) {
                add (item);
                reorder_child (item, index);
            }
        }
    }

    public void remove_indicator (Indicator indicator) {
        foreach (var entry in sorted_items) {
            if (entry.base_indicator.code_name == indicator.code_name) {
                sorted_items.remove (entry);
                remove (entry);
            }
        }
    }
}

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

public class Wingpanel.Widgets.IndicatorMenuBar : MenuBar {
    private Gee.List<IndicatorEntry> sorted_items;
    private Services.IndicatorSorter sorter = new Services.IndicatorSorter ();

    public IndicatorMenuBar () {
        sorted_items = new Gee.ArrayList<IndicatorEntry> ();
    }

    public void insert_sorted (IndicatorEntry item) {
        if (item in sorted_items) {
            return; /* item already added */
        }

        item.menu_bar = this;

        sorted_items.add (item);
        sorted_items.sort (sorter.compare_func);

        apply_new_order ();
    }

    public override void remove (Gtk.Widget widget) {
        var indicator_widget = widget as IndicatorEntry;

        if (indicator_widget != null) {
            sorted_items.remove (indicator_widget);
        }

        base.remove (widget);
    }

    public void apply_new_order () {
        clear ();
        append_all_items ();
    }

    private void clear () {
        var children = this.get_children ();

        foreach (var child in children) {
            base.remove (child);
        }
    }

    private void append_all_items () {
        foreach (var widget in sorted_items) {
            if (widget.base_indicator.visible) {
                this.append (widget);
            }
        }
    }
}
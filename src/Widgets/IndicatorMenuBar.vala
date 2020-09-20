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
    private uint apply_new_order_idle_id = 0;

    public IndicatorMenuBar () {
        sorted_items = new Gee.ArrayList<IndicatorEntry> ();
    }

    public void insert_sorted (IndicatorEntry item) {
        foreach (var indicator in sorted_items) {
            if (item.base_indicator.code_name == indicator.base_indicator.code_name) {
                return; /* item already added */
            }
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
        if (apply_new_order_idle_id > 0) {
            GLib.Source.remove (apply_new_order_idle_id);
            apply_new_order_idle_id = 0;
        }
        apply_new_order_idle_id = GLib.Idle.add_full (GLib.Priority.LOW, () => {
            clear ();
            append_all_items ();
            apply_new_order_idle_id = 0;
            return false;
        });
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

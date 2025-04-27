/*
 * Copyright (c) 2011-2015 Ikey Doherty <ikey@solus-project.com>
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

public class Wingpanel.Services.PopoverManager : Object {
    public bool indicator_open { get; private set; default = false; }

    private Gee.HashMap<string, Wingpanel.Widgets.IndicatorEntry> registered_indicators;
    private Wingpanel.Widgets.IndicatorPopover popover;
    private Wingpanel.Widgets.IndicatorEntry? _current_indicator = null;
    public Wingpanel.Widgets.IndicatorEntry? current_indicator {
        get {
            return _current_indicator;
        }

        set {
            if (value == null && _current_indicator == null) {
                return;
            }

            if (_current_indicator == null && value != null) { // First open
                indicator_open = true;
                _current_indicator = value;
            } else if (value == null && _current_indicator != null) { // Close requested
                indicator_open = false;
                _current_indicator.base_indicator.closed ();
                _current_indicator = null;
            } else if (_current_indicator.base_indicator.code_name == value.base_indicator.code_name) { // Close due to toggle
                _current_indicator.base_indicator.closed ();
                _current_indicator = null;
            } else { // Switch
                update_has_tooltip (_current_indicator.display_widget);
                _current_indicator.base_indicator.closed ();
                _current_indicator = value;
                popover.unparent ();
            }

            if (_current_indicator != null) {
                popover.set_content (_current_indicator.indicator_widget);
                update_has_tooltip (_current_indicator.display_widget, false);
                popover.set_parent (_current_indicator);
                popover.popup ();
                _current_indicator.base_indicator.opened ();
            } else {
                update_has_tooltip (((Wingpanel.Widgets.IndicatorEntry)popover.parent).display_widget);
                popover.popdown ();
            }
        }
    }

    public PopoverManager () {
        registered_indicators = new Gee.HashMap<string, Wingpanel.Widgets.IndicatorEntry> ();

        popover = new Wingpanel.Widgets.IndicatorPopover ();

        popover.closed.connect (() => {
            current_indicator = null;
            popover.unparent ();
        });
    }

    public void set_popover_visible (string code_name, bool visible) {
        if (registered_indicators.has_key (code_name)) {
            var new_indicator = registered_indicators.get (code_name);

            if (visible && (current_indicator == null || current_indicator.base_indicator.code_name != new_indicator.base_indicator.code_name)) {
                current_indicator = new_indicator;
            } else if (current_indicator.base_indicator.code_name == new_indicator.base_indicator.code_name && !visible) {
                current_indicator = null;
            }
        }
    }

    public void toggle_popover_visible (string code_name) {
        if (registered_indicators.has_key (code_name)) {
            current_indicator = registered_indicators.get (code_name);
        }
    }

    public bool get_visible (Wingpanel.Widgets.IndicatorEntry entry) {
        return current_indicator != null && current_indicator.base_indicator.code_name == entry.base_indicator.code_name;
    }

    private void update_has_tooltip (Gtk.Widget display_widget, bool enable = true) {
        if (display_widget != null) {
            display_widget.has_tooltip = enable;
        }
    }

    public void close () {
        if (current_indicator != null) {
            current_indicator = null;
        }
    }

    public void unregister_indicator (Wingpanel.Widgets.IndicatorEntry? widg) {
        if (registered_indicators.has_key (widg.base_indicator.code_name)) {
            registered_indicators.unset (widg.base_indicator.code_name);
        }
    }

    public void register_indicator (Wingpanel.Widgets.IndicatorEntry? widg) {
        if (registered_indicators.has_key (widg.base_indicator.code_name)) {
            return;
        }

        registered_indicators.set (widg.base_indicator.code_name, widg);
    }
}

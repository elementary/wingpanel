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
    private unowned Wingpanel.PanelWindow? owner;

    private bool grabbed = false; // whether the wingpanel grabbed focus
    private bool mousing = false;

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
                _current_indicator = value;
            } else if (value == null && _current_indicator != null) { // Close requested
                _current_indicator.base_indicator.closed ();
                _current_indicator = null;
            } else if (_current_indicator.base_indicator.code_name == value.base_indicator.code_name) { // Close due to toggle
                return;
                _current_indicator.base_indicator.closed ();
                _current_indicator = null;
            } else { // Switch
                update_has_tooltip (_current_indicator.display_widget);
                _current_indicator.base_indicator.closed ();
                _current_indicator = value;
            }

            popover.unparent ();

            if (_current_indicator != null) {
                popover.set_content (_current_indicator.indicator_widget);
                popover.set_parent (_current_indicator);
                update_has_tooltip (_current_indicator.display_widget, false);
                owner.present ();
                popover.position = BOTTOM;
                popover.popup ();
                _current_indicator.base_indicator.opened ();
            } else {
                update_has_tooltip (((Wingpanel.Widgets.IndicatorEntry)popover.parent).display_widget);
                popover.popdown ();
            }
        }
    }

    public PopoverManager (Wingpanel.PanelWindow? owner) {
        registered_indicators = new Gee.HashMap<string, Wingpanel.Widgets.IndicatorEntry> ();

        this.owner = owner;

        popover = new Wingpanel.Widgets.IndicatorPopover ();
        popover.closed.connect (() => current_indicator = null);
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
            warning ("HAS KEy: %s", widg.base_indicator.code_name);
            return;
        }
        warning ("Register indicator: %s", widg.base_indicator.code_name);
        registered_indicators.set (widg.base_indicator.code_name, widg);

        //  widg.enter_notify_event.connect ((w, e) => {
        //      if (mousing) {
        //          return Gdk.EVENT_PROPAGATE;
        //      }

        //      if (grabbed) {
        //          if (!get_visible (widg) && e.mode != Gdk.CrossingMode.TOUCH_BEGIN) {
        //              mousing = true;
        //              current_indicator = widg;
        //              mousing = false;
        //          }

        //          return Gdk.EVENT_STOP;
        //      }

        //      return Gdk.EVENT_PROPAGATE;
        //  });

        widg.notify["visible"].connect (() => {
            if (mousing || grabbed) {
                return;
            }

            if (get_visible (widg)) {
                current_indicator = null;
            }
        });
    }
}

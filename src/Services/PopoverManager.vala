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

    private bool grabbed = false;
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
                _current_indicator.base_indicator.closed ();
                _current_indicator = null;
            } else { // Switch
                _current_indicator.base_indicator.closed ();
                _current_indicator = value;
            }

            if (_current_indicator != null) {
                popover.set_content (_current_indicator.indicator_widget);
                popover.relative_to = _current_indicator;
                owner.set_expanded (true);
                make_modal (popover, true);
                owner.present ();
                popover.popup ();
                popover.show_all ();
                _current_indicator.base_indicator.opened ();
            } else {
                popover.popdown ();
            }
        }
    }

    public PopoverManager (Wingpanel.PanelWindow? owner) {
        registered_indicators = new Gee.HashMap<string, Wingpanel.Widgets.IndicatorEntry>();

        this.owner = owner;

        popover = new Wingpanel.Widgets.IndicatorPopover ();

        popover.leave_notify_event.connect ((e) => {
            Gtk.Allocation allocation;
            popover.get_allocation (out allocation);

            if (e.mode != Gdk.CrossingMode.NORMAL && e.subwindow == null) {
                current_indicator = null;
            }

            return Gdk.EVENT_PROPAGATE;
        });

        popover.closed.connect (() => {
            make_modal (popover, false);
            owner.set_expanded (false);
        });

        owner.focus_out_event.connect ((e) => {
            if (mousing) {
                return Gdk.EVENT_PROPAGATE;
            }

            if (current_indicator != null && e.window == null) {
                current_indicator = null;
            }

            return Gdk.EVENT_PROPAGATE;
        });

        owner.button_press_event.connect ((w, e) => {
            // "owner" is the invisible window that fills the screen when an indicator is open, if the event didn't hit
            // that window directly, then it was probably in the popover, so propagate it.
            if (e.window != owner.get_window ()) {
                return Gdk.EVENT_PROPAGATE;
            }

            Gtk.Allocation allocation;
            popover.get_allocation (out allocation);

            Gtk.Allocation indicator_allocation;
            current_indicator.get_allocation (out indicator_allocation);

            Gtk.Allocation container_allocation;
            current_indicator.get_parent ().get_allocation (out container_allocation);

            int wingpanel_width;
            owner.get_root_window ().get_geometry (null, null, out wingpanel_width, null);

            allocation.x += indicator_allocation.x +
                            container_allocation.x -
                            ((allocation.width - indicator_allocation.width) / 2);

            if (allocation.x < 0) {
                allocation.x = 0;
            }

            if (allocation.x + allocation.width > wingpanel_width) {
                allocation.x = wingpanel_width - allocation.width;
            }

            if ((e.x < allocation.x || e.x > allocation.x + allocation.width) || (e.y < allocation.y || e.y > allocation.y + allocation.height)) {
                current_indicator = null;
            }

            return Gdk.EVENT_STOP;
        });

        owner.add_events (Gdk.EventMask.POINTER_MOTION_MASK | Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.BUTTON_PRESS_MASK);
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

    private void make_modal (Gtk.Popover? pop, bool modal = true) {
        if (pop == null || pop.get_window () == null || mousing) {
            return;
        }

        if (modal && !grabbed) {
            grabbed = true;
            Gtk.grab_add (owner);
            owner.set_focus (null);
            pop.grab_focus ();
        } else if (!modal && grabbed) {
            grabbed = false;
            Gtk.grab_remove (owner);
            owner.grab_focus ();
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

        widg.enter_notify_event.connect ((w, e) => {
            if (mousing) {
                return Gdk.EVENT_PROPAGATE;
            }

            if (grabbed) {
                if (!get_visible (widg) && e.mode != Gdk.CrossingMode.TOUCH_BEGIN) {
                    mousing = true;
                    current_indicator = widg;
                    mousing = false;
                }

                return Gdk.EVENT_STOP;
            }

            return Gdk.EVENT_PROPAGATE;
        });

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

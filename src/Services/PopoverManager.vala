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
    public unowned Wingpanel.PanelWindow owner { get; construct; }

    private Gtk.Popover popover;

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
                _current_indicator.set_state_flags (NORMAL, true);
                _current_indicator = null;
            } else if (_current_indicator.base_indicator.code_name == value.base_indicator.code_name) { // Close due to toggle
                _current_indicator.set_state_flags (NORMAL, true);
                _current_indicator.base_indicator.closed ();
                _current_indicator = null;
            } else { // Switch
                _current_indicator.set_state_flags (NORMAL, true);
                _current_indicator.display_widget.has_tooltip = true;
                _current_indicator.base_indicator.closed ();
                _current_indicator = value;
                popover.unparent ();
            }

            if (_current_indicator != null) {
                popover.child = _current_indicator.indicator_widget;
                _current_indicator.display_widget.has_tooltip = false;
                popover.set_parent (_current_indicator);
                _current_indicator.base_indicator.opened ();
                GtkLayerShell.set_keyboard_mode (owner, GtkLayerShell.KeyboardMode.ON_DEMAND);
                popover.popup ();
                _current_indicator.set_state_flags (CHECKED, true);
                if (owner.is_active) {
                    _current_indicator.indicator_widget.child_focus (Gtk.DirectionType.TAB_FORWARD);
                } else {
                    ulong handler_id = 0;
                    handler_id = owner.notify["is-active"].connect (() => {
                        if (owner.is_active && _current_indicator != null) {
                            _current_indicator.indicator_widget.child_focus (Gtk.DirectionType.TAB_FORWARD);
                            SignalHandler.disconnect (owner, handler_id);
                        }
                    });
                }
            } else {
                ((Widgets.IndicatorEntry)popover.parent).display_widget.has_tooltip = true;
                GtkLayerShell.set_keyboard_mode (owner, GtkLayerShell.KeyboardMode.NONE);
                popover.popdown ();
            }
        }
    }

    public PopoverManager (Wingpanel.PanelWindow owner) {
        Object (owner: owner);
    }

    construct {
        popover = new Gtk.Popover () {
            has_arrow = false,
            position = BOTTOM
        };
        popover.add_css_class ("indicator");

        popover.closed.connect (() => {
            _current_indicator.set_state_flags (NORMAL, true);
            current_indicator = null;
            popover.unparent ();
        });
    }
}

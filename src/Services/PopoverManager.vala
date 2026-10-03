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
                _current_indicator = value;
                indicator_open = true;
            } else if (value == null && _current_indicator != null) { // Close requested
                _current_indicator.set_state_flags (NORMAL, true);
                _current_indicator.display_widget.has_tooltip = true;
                _current_indicator.base_indicator.closed ();
                _current_indicator = null;
                popover.popdown ();
                indicator_open = false;
            } else { // Switch
                _current_indicator.set_state_flags (NORMAL, true);
                _current_indicator.display_widget.has_tooltip = true;
                _current_indicator.base_indicator.closed ();
                _current_indicator = value;
            }

            if (_current_indicator != null) {
                popover.child = _current_indicator.indicator_widget;
                // Only reparent when the popover actually needs to move to a
                // different indicator. Unparenting destroys the popover's
                // surface and set_parent () builds a new one; doing that on
                // every open/close cycle eventually leaves the popover
                // unmapped (visible but never drawn) and ends in a Wayland
                // protocol error.
                if (popover.parent != _current_indicator) {
                    if (popover.parent != null) {
                        popover.unparent ();
                    }

                    popover.set_parent (_current_indicator);
                }

                popover.popup ();

                _current_indicator.set_state_flags (CHECKED, true);
                _current_indicator.display_widget.has_tooltip = false;
                _current_indicator.base_indicator.opened ();
            }
        }
    }

    public void close () {
        current_indicator = null;
    }

    construct {
        popover = new Gtk.Popover () {
            has_arrow = false,
            position = BOTTOM,
            // autohide makes GTK request an xdg_popup grab. Wayland only grants
            // that grab against a recent input event serial, and a popover
            // opened from a keybinding has received no input at all, so the
            // compositor refuses the popup and it is never mapped. Dismissal
            // is handled by PanelWindow watching the toplevel focus state.
            autohide = false
        };
        popover.add_css_class ("indicator");

        popover.closed.connect (() => {
            // Fires for closes the setter already handled (it nulls
            // _current_indicator before the asynchronous popdown), so guard
            // against dereferencing null. Deliberately does NOT unparent: the
            // popover stays parented to its indicator and is only moved when a
            // different indicator is opened.
            if (_current_indicator != null) {
                _current_indicator.set_state_flags (NORMAL, true);
                current_indicator = null;
            }
        });
    }
}

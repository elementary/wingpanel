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
            // Double close. Shouldn't happen?
            if (value == null && _current_indicator == null) {
                return;
            }

            // Switch or Close
            if (_current_indicator != null) {
                _current_indicator.set_state_flags (NORMAL, true);
                _current_indicator.display_widget.has_tooltip = true;
                _current_indicator.base_indicator.closed ();

                // Close
                if (value == null) {
                    popover.popdown ();
                    popover.unparent ();
                    _current_indicator = null;
                    indicator_open = false;
                    return;
                } else {
                    popover.unparent ();
                }
            }

            // First open
            if (_current_indicator == null) {
                indicator_open = true;
            }

            _current_indicator = value;
            _current_indicator.set_state_flags (CHECKED, true);
            _current_indicator.display_widget.has_tooltip = false;

            popover.child = _current_indicator.indicator_widget;
            popover.set_parent (_current_indicator);

            // Make sure display_widget is parented beforehand
            _current_indicator.base_indicator.opened ();
            popover.popup ();
        }
    }

    construct {
        popover = new Gtk.Popover () {
            has_arrow = false,
            position = BOTTOM
        };
        popover.add_css_class ("indicator");

        popover.closed.connect (() => {
            current_indicator = null;
        });
    }
}

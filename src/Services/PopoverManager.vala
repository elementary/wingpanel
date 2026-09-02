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
                value.open_popover ();
                _current_indicator = value;
            } else if (value == null && _current_indicator != null) { // Close requested
                indicator_open = false;
                _current_indicator.close_popover ();
                _current_indicator = null;
            } else if (_current_indicator == value) { // Close due to toggle
                indicator_open = false;
                _current_indicator.close_popover ();
                _current_indicator = null;
            } else { // Switch
                indicator_open = true;
                _current_indicator.close_popover ();

                value.open_popover ();
                _current_indicator = value;
            }
        }
    }
}

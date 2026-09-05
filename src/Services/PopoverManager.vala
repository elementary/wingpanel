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

    private Adw.TimedAnimation fade;
    private Adw.TimedAnimation scale;
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
                set_revealed (true);
                _current_indicator.set_state_flags (CHECKED, true);
                _current_indicator.base_indicator.opened ();
            } else {
                ((Widgets.IndicatorEntry)popover.parent).display_widget.has_tooltip = true;
                set_revealed (false);
            }
        }
    }

    construct {
        popover = new Gtk.Popover () {
            halign = CENTER,
            has_arrow = false,
            position = BOTTOM
        };
        popover.add_css_class ("indicator");

        fade = new Adw.TimedAnimation (
            popover, 0, 1,
            Granite.TRANSITION_DURATION_OPEN,
            new Adw.PropertyAnimationTarget (popover, "opacity")
        ) {
            easing = EASE_IN_OUT_QUAD
        };

        var scale_target = new Adw.CallbackAnimationTarget ((val) => {
            var height = _current_indicator.indicator_widget.get_height ();
            var width = _current_indicator.indicator_widget.get_width ();

            var center_x = (width - (val * width)) / 2.0;

            _current_indicator.indicator_widget.allocate (
                width, height, -1,
                new Gsk.Transform ()
                    .scale ((float) val, (float) val)
            );

            var popover_height = popover.get_height ();
            var popover_width = popover.get_width ();

            popover.present ();
            popover.size_allocate (
                (int) (popover_width * val), (int) (popover_height * val), -1
            );
        });

        scale = new Adw.TimedAnimation (
            popover, 0.5, 1,
            Granite.TRANSITION_DURATION_OPEN,
            scale_target
        ) {
            easing = EASE_IN_OUT_QUAD
        };

        popover.closed.connect (() => {
            _current_indicator.set_state_flags (NORMAL, true);
            current_indicator = null;
            popover.unparent ();
        });
    }

    private void set_revealed (bool revealed) {
        fade.skip ();
        scale.skip ();

        // Avoid a stutter at the beginning
        popover.opacity = 0;

        fade.reverse = !revealed;

        if (revealed) {
            popover.popup ();
            fade.duration = Granite.TRANSITION_DURATION_OPEN;
            scale.duration = Granite.TRANSITION_DURATION_OPEN;
            scale.easing = EASE_IN_OUT_QUAD;
        } else {
            fade.duration = Granite.TRANSITION_DURATION_CLOSE;
            scale.duration = Granite.TRANSITION_DURATION_CLOSE;
            scale.easing = EASE_IN_OUT_QUAD;
        }

        fade.play ();
        scale.play ();
    }
}

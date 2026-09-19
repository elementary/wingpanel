/*
 * Copyright 2026 elementary, Inc. (https://elementary.io)
 *           2011-2015 Ikey Doherty <ikey@solus-project.com>
 * SPDX-License-Identifier: GPL-2.0-or-later
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

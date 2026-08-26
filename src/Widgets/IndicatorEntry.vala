/*
 * Copyright 2011-2020 elementary, Inc. (https://elementary.io)
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

public class Wingpanel.Widgets.IndicatorEntry : Granite.Bin {
    public Indicator base_indicator { get; construct; }
    public Services.PopoverManager popover_manager { get; construct; }

    public IndicatorBar? indicator_bar { get; set; }
    public Gtk.Widget display_widget { get; private set; }

    private Gtk.Widget _indicator_widget = null;
    public unowned Gtk.Widget indicator_widget {
        get {
            if (_indicator_widget == null) {
                _indicator_widget = base_indicator.get_widget ();
            }

            return _indicator_widget;
        }
    }

    public IndicatorEntry (Indicator base_indicator, Services.PopoverManager popover_manager) {
        Object (
            base_indicator: base_indicator,
            popover_manager: popover_manager
        );
    }

    construct {
        display_widget = base_indicator.get_display_widget ();
        name = base_indicator.code_name + "/entry";

        if (display_widget == null) {
            return;
        }

        var revealer = new Gtk.Revealer () {
            child = display_widget
        };
        revealer.add_css_class ("composited-indicator");

        switch (base_indicator.code_name) {
            case Indicator.APP_LAUNCHER:
                revealer.transition_type = SLIDE_RIGHT;
                break;
            case Indicator.DATETIME:
                revealer.transition_type = SLIDE_DOWN;
                break;
            default:
                revealer.transition_type = SLIDE_LEFT;
                break;
        }

        child = revealer;

        if (base_indicator.visible) {
            popover_manager.register_indicator (this);
        }

        base_indicator.notify["visible"].connect (() => {
            if (indicator_bar == null) {
                return;
            }

            if (base_indicator.visible) {
                popover_manager.register_indicator (this);
                indicator_bar.insert_sorted (this);
            } else {
                popover_manager.unregister_indicator (this);
                // reorder indicators when indicator is invisible
                display_widget.unmap.connect (indicator_unmapped);
            }
        });

        var gesture_controller = new Gtk.GestureClick ();
        gesture_controller.pressed.connect (() => {
            popover_manager.current_indicator = this;
            gesture_controller.set_state (CLAIMED);
        });

        var motion_controller = new Gtk.EventControllerMotion () {
            propagation_phase = CAPTURE
        };
        motion_controller.enter.connect (() => {
            // If something is open and it's not us, open us. This implements the scrubbing behavior
            if (popover_manager.current_indicator != null && !popover_manager.get_visible (this)) {
                popover_manager.current_indicator = this;
            }
        });

        add_controller (gesture_controller);
        add_controller (motion_controller);

        base_indicator.bind_property ("visible", revealer, "reveal-child", SYNC_CREATE);
    }

    private void indicator_unmapped () {
        base_indicator.get_display_widget ().unmap.disconnect (indicator_unmapped);
        indicator_bar.remove (this);
    }
}

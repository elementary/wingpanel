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

    public IndicatorBar? indicator_bar;
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

    private Gtk.Revealer revealer;

    private Gtk.GestureClick gesture_controller;
    private Gtk.EventControllerMotion motion_controller;

    public IndicatorEntry (Indicator base_indicator, Services.PopoverManager popover_manager) {
        Object (
            base_indicator: base_indicator,
            popover_manager: popover_manager
        );
    }

    construct {
        can_focus = false;
        display_widget = base_indicator.get_display_widget ();
        halign = Gtk.Align.START;
        name = base_indicator.code_name + "/entry";

        if (display_widget == null) {
            return;
        }

        revealer = new Gtk.Revealer () {
            child = display_widget
        };
        revealer.get_style_context ().add_class ("composited-indicator");

        child = revealer;

        if (base_indicator.visible) {
            popover_manager.register_indicator (this);
        }

        base_indicator.close.connect (() => {
            popover_manager.close ();
        });

        base_indicator.notify["visible"].connect (() => {
            if (indicator_bar != null) {
                /* order will be changed so close all open popovers */
                popover_manager.close ();

                if (base_indicator.visible) {
                    popover_manager.register_indicator (this);
                    indicator_bar.insert_sorted (this);
                    set_reveal (base_indicator.visible);
                } else {
                    set_reveal (base_indicator.visible);
                    popover_manager.unregister_indicator (this);
                    // reorder indicators when indicator is invisible
                    display_widget.unmap.connect (indicator_unmapped);
                }
            } else {
                set_reveal (base_indicator.visible);
            }
        });

        gesture_controller = new Gtk.GestureClick ();
        add_controller (gesture_controller);
        gesture_controller.pressed.connect (() => {
            popover_manager.current_indicator = this;
            gesture_controller.set_state (CLAIMED);
        });

        motion_controller = new Gtk.EventControllerMotion () {
            propagation_phase = CAPTURE
        };
        add_controller (motion_controller);

        motion_controller.enter.connect (() => {
            // If something is open and it's not us, open us. This implements the scrubbing behavior
            if (popover_manager.current_indicator != null && !popover_manager.get_visible (this)) {
                popover_manager.current_indicator = this;
            }
        });

        set_reveal (base_indicator.visible);
    }

    private void indicator_unmapped () {
        base_indicator.get_display_widget ().unmap.disconnect (indicator_unmapped);
        indicator_bar.remove (this);
    }

    public void set_transition_type (Gtk.RevealerTransitionType transition_type) {
        revealer.set_transition_type (transition_type);
    }

    private void set_reveal (bool reveal) {
        if (!reveal && popover_manager.get_visible (this)) {
            popover_manager.current_indicator = null;
        }

        revealer.set_reveal_child (reveal);
    }
}

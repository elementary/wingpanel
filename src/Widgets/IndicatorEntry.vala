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
    private const string UNKNOWN_INDICATOR = "xxx-unknown";
    private const string AYATANA_INDICATOR = "xxx-ayatana";

    public Indicator base_indicator { get; construct; }
    public Services.PopoverManager popover_manager { get; construct; }

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

    public bool should_show_indicator {
        get {
            return revealer.reveal_child || revealer.child_revealed;
        }
    }

    /* The order in which the indicators are shown from left to right. */
    private static Gee.HashMap<string, int> indicator_order = new Gee.HashMap<string,int> ();

    private Gtk.Revealer revealer;

    private Gtk.GestureClick gesture_controller;
    private Gtk.EventControllerMotion motion_controller;

    public IndicatorEntry (Indicator base_indicator, Services.PopoverManager popover_manager) {
        Object (
            base_indicator: base_indicator,
            popover_manager: popover_manager
        );
    }

    static construct {
        indicator_order[AYATANA_INDICATOR] = 0;
        indicator_order[UNKNOWN_INDICATOR] = 1;
        indicator_order[Indicator.ACCESSIBILITY] = 2;
        indicator_order[Indicator.NIGHT_LIGHT] = 3;
        indicator_order[Indicator.PRIVACY] = 4;
        indicator_order[Indicator.KEYBOARD] = 5;
        indicator_order[Indicator.SOUND] = 6;
        indicator_order[Indicator.NETWORK] = 7;
        indicator_order[Indicator.BLUETOOTH] = 8;
        indicator_order[Indicator.PRINTER] = 9;
        indicator_order[Indicator.SYNC] = 10;
        indicator_order[Indicator.POWER] = 11;
        indicator_order[Indicator.MESSAGES] = 12;
        indicator_order[Indicator.QUICKSETTINGS] = 13;
        indicator_order[Indicator.SESSION] = 14;
    }

    class construct {
        set_css_name ("indicator");
    }

    construct {
        display_widget = base_indicator.get_display_widget ();
        halign = Gtk.Align.START;
        name = base_indicator.code_name + "/entry";

        if (display_widget == null) {
            return;
        }

        revealer = new Gtk.Revealer () {
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

        revealer.notify["child-revealed"].connect (() => notify_property ("should-show-indicator"));
        revealer.notify["reveal-child"].connect (() => notify_property ("should-show-indicator"));

        child = revealer;

        if (base_indicator.visible) {
            popover_manager.register_indicator (this);
        }

        base_indicator.close.connect (() => {
            popover_manager.close ();
        });

        base_indicator.notify["visible"].connect (() => {
            /* order will be changed so close all open popovers */
            popover_manager.close ();

            if (base_indicator.visible) {
                popover_manager.register_indicator (this);
                set_reveal (base_indicator.visible);
            } else {
                popover_manager.unregister_indicator (this);
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

    private void set_reveal (bool reveal) {
        if (!reveal && popover_manager.get_visible (this)) {
            popover_manager.current_indicator = null;
        }

        revealer.set_reveal_child (reveal);
    }

    public static int compare_func (Wingpanel.Widgets.IndicatorEntry? a, Wingpanel.Widgets.IndicatorEntry? b) {
        if (a == null) {
            return (b == null) ? 0 : -1;
        }

        if (b == null) {
            return 1;
        }

        int order = get_order (a) - get_order (b);

        /*
         * Whenever two different entries  are not part of the default order list,
         * we sort them using their individual name hints.
         */
        if (order == 0) {
            order = strcmp (a.base_indicator.code_name.down (), b.base_indicator.code_name.down ());
        }

        return order.clamp (-1, 1);
    }

    private static int get_order (Wingpanel.Widgets.IndicatorEntry node) {
        /* ayatana application indicators on the left of the native indicators */
        if (node.base_indicator.code_name.has_prefix ("ayatana-")) {
            return indicator_order[AYATANA_INDICATOR];
        }

        if (indicator_order.has_key (node.base_indicator.code_name)) {
            return indicator_order[node.base_indicator.code_name];
        }

        return indicator_order[UNKNOWN_INDICATOR];
    }
}

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

public class Wingpanel.Widgets.Panel : Granite.Bin {
    private static Settings panel_settings = new Settings ("io.elementary.desktop.wingpanel");

    public Services.PopoverManager popover_manager { get; construct; }

    private IndicatorBar right_menubar;
    private IndicatorBar left_menubar;
    private IndicatorBar center_menubar;

    private Gtk.CenterBox box;
    private Gtk.CssProvider? style_provider = null;

    private Gtk.GestureClick gesture_controller;
    private Gtk.EventControllerScroll scroll_controller;
    private double current_scroll_delta = 0;

    public Panel (Services.PopoverManager popover_manager) {
        Object (popover_manager : popover_manager);
    }

    class construct {
        set_css_name ("panel");
    }

    construct {
        height_request = 30;
        hexpand = true;
        vexpand = true;
        valign = START;

        left_menubar = new IndicatorBar () {
            halign = START
        };

        center_menubar = new IndicatorBar ();

        right_menubar = new IndicatorBar () {
            halign = END
        };

        box = new Gtk.CenterBox ();
        box.set_start_widget (left_menubar);
        box.set_center_widget (center_menubar);
        box.set_end_widget (right_menubar);

        child = box;

        unowned IndicatorManager indicator_manager = IndicatorManager.get_default ();
        indicator_manager.indicator_added.connect (add_indicator);
        indicator_manager.indicator_removed.connect (remove_indicator);

        indicator_manager.get_indicators ().@foreach ((indicator) => {
            add_indicator (indicator);

            return true;
        });

        Services.BackgroundManager.get_default ().background_state_changed.connect (update_background);

        gesture_controller = new Gtk.GestureClick ();
        add_controller (gesture_controller);
        gesture_controller.pressed.connect ((n_press, x, y) => {
            begin_drag (x, y);
            gesture_controller.set_state (CLAIMED);
            gesture_controller.reset ();
        });

        scroll_controller = new Gtk.EventControllerScroll (BOTH_AXES);
        add_controller (scroll_controller);
        scroll_controller.scroll_end.connect (() => current_scroll_delta = 0);
        scroll_controller.scroll.connect ((dx, dy) => {
            if (!panel_settings.get_boolean ("scroll-to-switch-workspaces")) {
                return Gdk.EVENT_PROPAGATE;
            }

            if (current_scroll_delta == 0) {
                Services.WMDBus.switch_workspace.begin (dx < 0 || dy < 0);
            }

            current_scroll_delta += dx + dy;

            if (current_scroll_delta.abs () > 10) { //TODO: Check whether 10 is good here.
                current_scroll_delta = 0;
            }
        });
    }

    private void begin_drag (double x, double y) {
        popover_manager.close ();

        var background_manager = Services.BackgroundManager.get_default ();
        background_manager.begin_grab_focused_window ((int) x, (int) y);
    }

    public void cycle (bool forward) {
        var current = popover_manager.current_indicator;
        if (current == null) {
            return;
        }

        IndicatorEntry? sibling;
        if (forward) {
            sibling = get_next_indicator (current);
        } else {
            sibling = get_previous_indicator (current);
        }

        if (sibling != null) {
            popover_manager.current_indicator = sibling;
        }
    }

    private IndicatorEntry? get_next_indicator (IndicatorEntry current) {
        Gtk.Widget? sibling = current.get_next_sibling ();

        if (sibling != null) {
            return (IndicatorEntry) sibling;
        }

        switch (current.base_indicator.code_name) {
            case Indicator.APP_LAUNCHER:
                return (IndicatorEntry) center_menubar.get_last_child ();
            case Indicator.DATETIME:
                return (IndicatorEntry) right_menubar.get_last_child ();
            default:
                return (IndicatorEntry) left_menubar.get_last_child ();
        }
    }

    private IndicatorEntry? get_previous_indicator (IndicatorEntry current) {
        Gtk.Widget? sibling = current.get_prev_sibling ();

        if (sibling != null) {
            return (IndicatorEntry) sibling;
        }

        switch (current.base_indicator.code_name) {
            case Indicator.APP_LAUNCHER:
                return (IndicatorEntry) right_menubar.get_last_child ();
            case Indicator.DATETIME:
                return (IndicatorEntry) left_menubar.get_last_child ();
            default:
                return (IndicatorEntry) center_menubar.get_last_child ();
        }
    }

    private void add_indicator (Indicator indicator) {
        var indicator_entry = new IndicatorEntry (indicator, popover_manager);

        switch (indicator.code_name) {
            case Indicator.APP_LAUNCHER:
                indicator_entry.set_transition_type (Gtk.RevealerTransitionType.SLIDE_RIGHT);
                left_menubar.insert_sorted (indicator_entry);
                break;
            case Indicator.DATETIME:
                indicator_entry.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
                center_menubar.insert_sorted (indicator_entry);
                break;
            default:
                indicator_entry.set_transition_type (Gtk.RevealerTransitionType.SLIDE_LEFT);
                right_menubar.insert_sorted (indicator_entry);
                break;
        }
    }

    private void remove_indicator (Indicator indicator) {
        left_menubar.remove_indicator (indicator);
        center_menubar.remove_indicator (indicator);
        right_menubar.remove_indicator (indicator);
    }

    private void update_background (Services.BackgroundState state, uint animation_duration) {
        if (style_provider == null) {
            style_provider = new Gtk.CssProvider ();
             Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                style_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            );
        }

        string css = """
            panel {
                transition: all %ums cubic-bezier(0.4, 0, 0.2, 1);
            }
        """.printf (animation_duration);

        style_provider.load_from_string (css);

        switch (state) {
            case Services.BackgroundState.DARK :
                css_classes = {"color-light"};
                break;
            case Services.BackgroundState.LIGHT:
                css_classes = {"color-dark"};
                break;
            case Services.BackgroundState.MAXIMIZED:
                css_classes = {"maximized"};
                break;
            case Services.BackgroundState.TRANSLUCENT_DARK:
                css_classes = {
                    "color-light",
                    "translucent"
                };
                break;
            case Services.BackgroundState.TRANSLUCENT_LIGHT:
                css_classes = {
                    "color-dark",
                    "translucent"
                };
                break;
        }
    }
}

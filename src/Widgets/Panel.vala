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

public class Wingpanel.Widgets.Panel : Gtk.EventBox {
    public Services.PopoverManager popover_manager { get; construct; }

    private IndicatorBar right_menubar;
    private IndicatorBar left_menubar;
    private IndicatorBar center_menubar;

    private unowned Gtk.StyleContext style_context;
    private Gtk.CssProvider? style_provider = null;

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

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        box.pack_start (left_menubar);
        box.set_center_widget (center_menubar);
        box.pack_end (right_menubar);

        add (box);

        unowned IndicatorManager indicator_manager = IndicatorManager.get_default ();
        indicator_manager.indicator_added.connect (add_indicator);
        indicator_manager.indicator_removed.connect (remove_indicator);

        indicator_manager.get_indicators ().@foreach ((indicator) => {
            add_indicator (indicator);

            return true;
        });

        style_context = get_style_context ();

        Services.BackgroundManager.get_default ().background_state_changed.connect (update_background);

        button_press_event.connect ((event) => {
            begin_drag (event.x_root, event.y_root);
            return Gdk.EVENT_PROPAGATE;
        });
    }

    private void begin_drag (double x, double y) {
        var window = get_window ();
        if (window == null) {
            return;
        }

        window.get_display ().get_default_seat ().ungrab ();

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
            sibling = get_next_sibling (current);
        } else {
            sibling = get_previous_sibling (current);
        }

        if (sibling != null) {
            popover_manager.current_indicator = sibling;
        }
    }

    private IndicatorEntry? get_next_sibling (IndicatorEntry current) {
        IndicatorEntry? sibling = null;

        switch (current.base_indicator.code_name) {
            case Indicator.APP_LAUNCHER:
                var children = left_menubar.get_children ();
                int index = children.index (current);
                if (index == -1) {
                    break;
                } else if (index < children.length () - 1) { // Has more than one indicator in the left menubar
                    sibling = children.nth_data (index + 1) as IndicatorEntry;
                } else { // No more indicators on the left
                    var center_children = center_menubar.get_children ();
                    if (center_children.length () > 0) {
                        sibling = center_children.first ().data as IndicatorEntry;
                    }
                }

                break;
            case Indicator.DATETIME:
                var children = center_menubar.get_children ();
                int index = children.index (current);
                if (index == -1) {
                    break;
                } else if (index < children.length () - 1) { // Has more than one indicator in the center menubar
                    sibling = children.nth_data (index + 1) as IndicatorEntry;
                } else { // No more indicators on the center
                    var right_children = right_menubar.get_children ();
                    if (right_children.length () > 0) {
                        sibling = right_children.first ().data as IndicatorEntry;
                    }
                }

                break;
            default:
                var children = right_menubar.get_children ();
                int index = children.index (current);
                if (index == -1) {
                    break;
                } else if (index < children.length () - 1) { // Has more than one indicator in the right menubar
                    sibling = children.nth_data (index + 1) as IndicatorEntry;
                } else { // No more indicators on the right
                    var left_children = left_menubar.get_children ();
                    if (left_children.length () > 0) {
                        sibling = left_children.first ().data as IndicatorEntry;
                    }
                }

                break;
        }

        return sibling;
    }

    private IndicatorEntry? get_previous_sibling (IndicatorEntry current) {
        IndicatorEntry? sibling = null;

        switch (current.base_indicator.code_name) {
            case Indicator.APP_LAUNCHER:
                var children = left_menubar.get_children ();
                int index = children.index (current);
                if (index == -1) {
                    break;
                } else if (index != 0) { // Is not the first indicator in the left menubar
                    sibling = children.nth_data (index - 1) as IndicatorEntry;
                } else { // No more indicators on the left
                    var right_children = right_menubar.get_children ();
                    if (right_children.length () > 0) {
                        sibling = right_children.last ().data as IndicatorEntry;
                    }
                }

                break;
            case Indicator.DATETIME:
                var children = center_menubar.get_children ();
                int index = children.index (current);
                if (index == -1) {
                    break;
                } else if (index != 0) { // Is not the first indicator in the center menubar
                    sibling = children.nth_data (index - 1) as IndicatorEntry;
                } else { // No more indicators on the center
                    var left_children = left_menubar.get_children ();
                    if (left_children.length () > 0) {
                        sibling = left_children.last ().data as IndicatorEntry;
                    }
                }

                break;
            default:
                var children = right_menubar.get_children ();
                int index = children.index (current);
                if (index == -1) {
                    break;
                } else if (index != 0) { // Is not the first indicator in the right menubar
                    sibling = children.nth_data (index - 1) as IndicatorEntry;
                } else { // No more indicators on the right
                    var center_children = center_menubar.get_children ();
                    if (center_children.length () > 0) {
                        sibling = center_children.last ().data as IndicatorEntry;
                    }
                }

                break;
        }

        return sibling;
    }

    private void add_indicator (Indicator indicator) {
        var indicator_entry = new IndicatorEntry (indicator, popover_manager);

        switch (indicator.code_name) {
            case Indicator.APP_LAUNCHER:
                indicator_entry.set_transition_type (Gtk.RevealerTransitionType.SLIDE_RIGHT);
                left_menubar.add (indicator_entry);
                break;
            case Indicator.DATETIME:
                indicator_entry.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
                center_menubar.add (indicator_entry);
                break;
            default:
                indicator_entry.set_transition_type (Gtk.RevealerTransitionType.SLIDE_LEFT);
                right_menubar.insert_sorted (indicator_entry);
                break;
        }

        indicator_entry.show_all ();
    }

    private void remove_indicator (Indicator indicator) {
        left_menubar.remove_indicator (indicator);
        center_menubar.remove_indicator (indicator);
        right_menubar.remove_indicator (indicator);
    }

    private void update_background (Services.BackgroundState state, uint animation_duration) {
        if (style_provider == null) {
            style_provider = new Gtk.CssProvider ();
            style_context.add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        string css = """
            .panel {
                transition: all %ums cubic-bezier(0.4, 0, 0.2, 1);
            }
        """.printf (animation_duration);

        try {
            style_provider.load_from_data (css, css.length);
        } catch (Error e) {
            warning ("Parsing own style configuration failed: %s", e.message);
        }

        switch (state) {
            case Services.BackgroundState.DARK :
                style_context.add_class ("color-light");
                style_context.remove_class ("color-dark");
                style_context.remove_class ("maximized");
                style_context.remove_class ("translucent");
                break;
            case Services.BackgroundState.LIGHT:
                style_context.add_class ("color-dark");
                style_context.remove_class ("color-light");
                style_context.remove_class ("maximized");
                style_context.remove_class ("translucent");
                break;
            case Services.BackgroundState.MAXIMIZED:
                style_context.add_class ("maximized");
                style_context.remove_class ("color-light");
                style_context.remove_class ("color-dark");
                style_context.remove_class ("translucent");
                break;
            case Services.BackgroundState.TRANSLUCENT_DARK:
                style_context.add_class ("translucent");
                style_context.add_class ("color-light");
                style_context.remove_class ("color-dark");
                style_context.remove_class ("maximized");
                break;
            case Services.BackgroundState.TRANSLUCENT_LIGHT:
                style_context.add_class ("translucent");
                style_context.add_class ("color-dark");
                style_context.remove_class ("color-light");
                style_context.remove_class ("maximized");
                break;
        }
    }
}

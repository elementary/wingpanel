/*
 * Copyright (c) 2011-2015 Wingpanel Developers (http://launchpad.net/wingpanel)
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

    private IndicatorMenuBar right_menubar;
    private MenuBar left_menubar;
    private MenuBar center_menubar;

    private Gtk.StyleContext style_context;
    private Gtk.CssProvider? style_provider = null;

    public Panel (Services.PopoverManager popover_manager) {
        Object (popover_manager : popover_manager);

        this.set_size_request (-1, 24);

        this.hexpand = true;
        this.vexpand = true;
        this.valign = Gtk.Align.START;
        this.get_style_context ().add_class (StyleClass.PANEL);

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

        left_menubar = new MenuBar ();
        left_menubar.halign = Gtk.Align.START;
        box.pack_start (left_menubar);

        center_menubar = new MenuBar ();
        box.set_center_widget (center_menubar);

        right_menubar = new IndicatorMenuBar ();
        right_menubar.halign = Gtk.Align.END;
        box.pack_end (right_menubar);

        add (box);

        unowned IndicatorManager indicator_manager = IndicatorManager.get_default ();
        indicator_manager.indicator_added.connect (add_indicator);
        indicator_manager.indicator_removed.connect (remove_indicator);

        indicator_manager.get_indicators ().@foreach ((indicator) => {
            add_indicator (indicator);

            return true;
        });

        style_context = this.get_style_context ();

        Services.BackgroundManager.get_default ().background_state_changed.connect (update_background);
    }

    public override bool button_press_event (Gdk.EventButton event) {
        if (event.button != Gdk.BUTTON_PRIMARY) {
            return Gdk.EVENT_PROPAGATE;
        }

        var window = get_window ();
        if (window == null) {
            return Gdk.EVENT_PROPAGATE;
        }

        // Grabbing with touchscreen on X does not work unfortunately
        if (event.device.get_source () == Gdk.InputSource.TOUCHSCREEN) {
            return Gdk.EVENT_PROPAGATE;
        }

        uint32 time = event.time;
        
#if HAS_GTK320
        window.get_display ().get_default_seat ().ungrab ();
#else
        window.get_display ().pointer_ungrab (time);
#endif

        Gdk.ModifierType state;
        event.get_state (out state);

        popover_manager.close ();

        var scale_factor = this.get_scale_factor ();
        var x = (int)event.x_root * scale_factor;
        var y = (int)event.y_root * scale_factor;

        var background_manager = Services.BackgroundManager.get_default ();
        return background_manager.begin_grab_focused_window (x, y, (int)event.button, time, state);
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
        remove_indicator_from_container (left_menubar, indicator);
        remove_indicator_from_container (center_menubar, indicator);
        remove_indicator_from_container (right_menubar, indicator);
    }

    private void remove_indicator_from_container (Gtk.Container container, Indicator indicator) {
        foreach (unowned Gtk.Widget child in container.get_children ()) {
            unowned IndicatorEntry? entry = (child as IndicatorEntry);

            if (entry != null && entry.base_indicator == indicator) {
                container.remove (child);

                return;
            }
        }
    }

    private void update_background (Services.BackgroundState state, uint animation_duration) {
        if (style_provider == null) {
            style_provider = new Gtk.CssProvider ();
            style_context.add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        string css = """
            .panel {
                transition: all %ums ease-in-out;
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

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

public class Wingpanel.Widgets.Panel : Gtk.Widget {
    public Services.PopoverManager popover_manager { get; construct; }

    private IndicatorMenuBar right_menubar;
    private IndicatorMenuBar left_menubar;
    private IndicatorMenuBar center_menubar;

    private unowned Gtk.StyleContext style_context;
    private Gtk.CssProvider? style_provider = null;

    public Panel (Services.PopoverManager popover_manager) {
        Object (popover_manager : popover_manager);
    }

    class construct {
        set_css_name ("panel");
    }

    construct {
        layout_manager = new Gtk.BinLayout ();
        height_request = 30;
        hexpand = true;
        vexpand = true;
        valign = Gtk.Align.START;

        left_menubar = new IndicatorMenuBar () {
            halign = Gtk.Align.START
        };

        center_menubar = new IndicatorMenuBar ();;

        right_menubar = new IndicatorMenuBar () {
            halign = Gtk.Align.END
        };

        var box = new Gtk.CenterBox ();
        box.start_widget = left_menubar;
        box.set_center_widget (center_menubar);
        box.set_end_widget (right_menubar);

        box.set_parent (this);

        unowned IndicatorManager indicator_manager = IndicatorManager.get_default ();
        indicator_manager.indicator_added.connect (add_indicator);
        indicator_manager.indicator_removed.connect (remove_indicator);

        indicator_manager.get_indicators ().@foreach ((indicator) => {
            add_indicator (indicator);

            return true;
        });

        style_context = get_style_context ();

        Services.BackgroundManager.get_default ().background_state_changed.connect (update_background);
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
                left_menubar.append (indicator_entry);
                break;
            case Indicator.DATETIME:
                indicator_entry.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);
                center_menubar.append (indicator_entry);
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
            style_context.add_provider (style_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        string css = """
            .panel {
                transition: all %ums cubic-bezier(0.4, 0, 0.2, 1);
            }
        """.printf (animation_duration);

        try {
            style_provider.load_from_string (css);
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

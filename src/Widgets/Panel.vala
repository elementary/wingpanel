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

    private ListStore all_indicator_entries;
    private Gtk.CustomFilter visible_indicator_entries_filter;
    private Gtk.FilterListModel visible_indicator_entries;
    private Gtk.SortListModel sorted_indicator_entries;

    private Gtk.CenterBox box;

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
        hexpand = true;
        vexpand = true;

        all_indicator_entries = new ListStore (typeof (IndicatorEntry));

        visible_indicator_entries_filter = new Gtk.CustomFilter (visible_indicators_filter_func);
        visible_indicator_entries = new Gtk.FilterListModel (
            all_indicator_entries,
            visible_indicator_entries_filter
        );

        sorted_indicator_entries = new Gtk.SortListModel (
            visible_indicator_entries,
            new Gtk.CustomSorter (IndicatorEntry.compare_func)
        );

        var left_indicator_entries = new Gtk.FilterListModel (
            sorted_indicator_entries,
            new Gtk.CustomFilter (left_indicators_filter_func)
        );
        var center_indicator_entries = new Gtk.FilterListModel (
            sorted_indicator_entries,
            new Gtk.CustomFilter (center_indicators_filter_func)
        );
        var right_indicator_entries = new Gtk.FilterListModel (
            sorted_indicator_entries,
            new Gtk.CustomFilter (right_indicators_filter_func)
        );

        left_menubar = new IndicatorBar (left_indicator_entries) {
            halign = START
        };

        center_menubar = new IndicatorBar (center_indicator_entries);

        right_menubar = new IndicatorBar (right_indicator_entries) {
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

        foreach (var indicator in indicator_manager.get_indicators ()) {
            add_indicator (indicator);
        }

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

            if (current_scroll_delta.abs () > 1) { // Balance between reactive and ignoring misinput
                current_scroll_delta = 0;
            }
        });

        var cycle_action = new SimpleAction ("cycle", null);
        cycle_action.activate.connect (() => cycle (TAB_FORWARD));

        var cycle_back_action = new SimpleAction ("cycle-back", null);
        cycle_back_action.activate.connect (() => cycle (TAB_BACKWARD));

        var action_group = new SimpleActionGroup ();
        action_group.add_action (cycle_action);
        action_group.add_action (cycle_back_action);

        insert_action_group ("panel", action_group);

        var cycle_shortcut = new Gtk.Shortcut (
            new Gtk.KeyvalTrigger (Gdk.Key.Tab, CONTROL_MASK),
            new Gtk.NamedAction ("panel.cycle")
        );
        var cycle_back_shortcut = new Gtk.Shortcut (
            new Gtk.KeyvalTrigger (Gdk.Key.Tab, CONTROL_MASK | SHIFT_MASK),
            new Gtk.NamedAction ("panel.cycle-back")
        );

        var shortcut_controller = new Gtk.ShortcutController () {
            propagation_phase = CAPTURE,
            propagation_limit = NONE // we need to listen to popover events
        };
        shortcut_controller.add_shortcut (cycle_shortcut);
        shortcut_controller.add_shortcut (cycle_back_shortcut);

        add_controller (shortcut_controller);
    }

    private void begin_drag (double x, double y) {
        popover_manager.close ();

        var background_manager = Services.BackgroundManager.get_default ();
        background_manager.begin_grab_focused_window ((int) x, (int) y);
    }

    private void cycle (Gtk.DirectionType direction) {
        var current = popover_manager.current_indicator;
        if (current == null) {
            return;
        }

        IndicatorEntry? sibling;
        if (direction == TAB_FORWARD) {
            sibling = get_next_indicator (current);
        } else {
            sibling = get_previous_indicator (current);
        }

        if (sibling != null) {
            popover_manager.current_indicator = sibling;
        }
    }

    private IndicatorEntry get_next_indicator (IndicatorEntry current) {
        var current_entry_pos = 0u;
        for (var i = 0; i < sorted_indicator_entries.get_n_items (); i++) {
            var indicator_entry = (IndicatorEntry) sorted_indicator_entries.get_item (i);
            if (indicator_entry == current) {
                current_entry_pos = i;
                break;
            }
        }

        var new_entry_pos = (current_entry_pos + 1).clamp (0, sorted_indicator_entries.get_n_items ());
        return (IndicatorEntry) sorted_indicator_entries.get_item (new_entry_pos);
    }

    private IndicatorEntry? get_previous_indicator (IndicatorEntry current) {
        var current_entry_pos = 0u;
        for (var i = 0; i < sorted_indicator_entries.get_n_items (); i++) {
            var indicator_entry = (IndicatorEntry) sorted_indicator_entries.get_item (i);
            if (indicator_entry == current) {
                current_entry_pos = i;
                break;
            }
        }

        var new_entry_pos = (current_entry_pos - 1).clamp (0, sorted_indicator_entries.get_n_items ());
        return (IndicatorEntry) sorted_indicator_entries.get_item (new_entry_pos);
    }

    private void add_indicator (Indicator indicator) {
        var indicator_entry = new IndicatorEntry (indicator, popover_manager);

        all_indicator_entries.append (indicator_entry);

        indicator_entry.notify["should-show-indicator"].connect (() =>
            visible_indicator_entries_filter.changed (DIFFERENT)
        );
    }

    private void remove_indicator (Indicator indicator) {
        for (var i = 0; i < all_indicator_entries.get_n_items (); i++) {
            var indicator_entry = (IndicatorEntry) all_indicator_entries.get_item (i);
            if (indicator_entry.base_indicator == indicator) {
                all_indicator_entries.remove (i);
            }
        }
    }

    private static bool visible_indicators_filter_func (Object item) requires (item is IndicatorEntry) {
        return ((IndicatorEntry) item).should_show_indicator;
    }

    private static bool left_indicators_filter_func (Object item) requires (item is IndicatorEntry) {
        return ((IndicatorEntry) item).base_indicator.code_name == Indicator.APP_LAUNCHER;
    }

    private static bool center_indicators_filter_func (Object item) requires (item is IndicatorEntry) {
        return ((IndicatorEntry) item).base_indicator.code_name == Indicator.DATETIME;
    }

    private static bool right_indicators_filter_func (Object item) requires (item is IndicatorEntry) {
        return !left_indicators_filter_func (item) && !center_indicators_filter_func (item);
    }
}

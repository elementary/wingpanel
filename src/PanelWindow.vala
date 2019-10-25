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

public class Wingpanel.PanelWindow : Gtk.Window {
    public Services.PopoverManager popover_manager;

    private Widgets.Panel panel;
    private int monitor_number;
    private int monitor_width;
    private int monitor_height;
    private int monitor_x;
    private int monitor_y;
    private int panel_height;
    private bool expanded = false;
    private int panel_displacement;

    public PanelWindow (Gtk.Application application) {
        Object (
            application: application,
            app_paintable: true,
            decorated: false,
            resizable: false,
            skip_pager_hint: true,
            skip_taskbar_hint: true,
            type_hint: Gdk.WindowTypeHint.DOCK,
            vexpand: false
        );

        monitor_number = screen.get_primary_monitor ();

        var style_context = get_style_context ();
        style_context.add_class (Widgets.StyleClass.PANEL);
        style_context.add_class (Gtk.STYLE_CLASS_MENUBAR);

        var provider = new Gtk.CssProvider ();
        provider.load_from_resource ("io/elementary/wingpanel/application.css");
        style_context.add_provider (provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        this.screen.size_changed.connect (update_panel_dimensions);
        this.screen.monitors_changed.connect (update_panel_dimensions);
        this.screen_changed.connect (update_visual);

        update_visual ();

        popover_manager = new Services.PopoverManager (this);

        panel = new Widgets.Panel (popover_manager);
        panel.realize.connect (on_realize);

        var cycle_action = new SimpleAction ("cycle", null);
        cycle_action.activate.connect (() => panel.cycle (true));

        var cycle_back_action = new SimpleAction ("cycle-back", null);
        cycle_back_action.activate.connect (() => panel.cycle (false));

        application.add_action (cycle_action);
        application.add_action (cycle_back_action);
        application.set_accels_for_action ("app.cycle", {"<Control>Tab"});
        application.set_accels_for_action ("app.cycle-back", {"<Control><Shift>Tab"});

        add (panel);
    }

    private bool animation_step () {
        if (panel_displacement <= panel_height * (-1)) {
            return false;
        }

        panel_displacement--;

        update_panel_dimensions ();

        return true;
    }

    private void on_realize () {
        update_panel_dimensions ();

        Services.BackgroundManager.initialize (this.monitor_number, panel_height);

        Timeout.add (300 / panel_height, animation_step);
    }

    private void update_panel_dimensions () {
        panel_height = panel.get_allocated_height ();

        monitor_number = screen.get_primary_monitor ();
        Gdk.Rectangle monitor_dimensions = get_display ().get_primary_monitor ().get_geometry ();

        monitor_width = monitor_dimensions.width;
        monitor_height = monitor_dimensions.height;

        this.set_size_request (monitor_width, (popover_manager.current_indicator != null ? monitor_height : -1));

        monitor_x = monitor_dimensions.x;
        monitor_y = monitor_dimensions.y;

        this.move (monitor_x, monitor_y - (panel_height + panel_displacement));

        update_struts ();
    }

    private void update_visual () {
        var visual = this.screen.get_rgba_visual ();

        if (visual == null) {
            warning ("Compositing not available, things will Look Bad (TM)");
        } else {
            this.set_visual (visual);
        }
    }

    private void update_struts () {
        if (!this.get_realized () || panel == null) {
            return;
        }

        /**
        * https://specifications.freedesktop.org/wm-spec/wm-spec-1.5.html#NETWMSTRUT
        * The _NET_WM_STRUCT_PARTICAL specification does not allow to reserve space for arbitrary rectangles 
        * on the screen. Instead it only allows to reserve space at the borders of screen. 
        * As for multi-monitor layouts the wingpanel can be at the within the screen (and not at the border)
        * this makes it impossible to reserve the correct space for all possible multi-monitor layouts.
        * Fortunately for up to 3 monitors there is always a possiblity to reserve the right space by also
        * using the struct-left and struct-right cardinals.
        */

        var display = get_display ();
        var n_monitors = display.get_n_monitors ();
        long struts[12] = {0};

        if (n_monitors == 1) {
            set_struts_from_top (struts);
        } else {
            var other_rects = new GLib.List <Gdk.Rectangle?> ();
            int screen_width = 0;

            for (var i = 0; i < n_monitors; i++) {
                var other_rect = display.get_monitor (i).get_geometry ();
                var end_x = other_rect.x + other_rect.width;

                if (end_x + 1 > screen_width) {
                    screen_width = end_x + 1;
                }

                other_rects.append (other_rect);
            }

            if (no_monitor_to_left (other_rects)) {
                set_struts_from_left (struts);
            } else if (no_monitor_to_right (other_rects, screen_width)) {
                set_struts_from_right (struts, screen_width);
            } else if (no_other_monitor_above (other_rects)) {
                set_struts_from_top (struts);
            }
        }

        Gdk.property_change (this.get_window (), Gdk.Atom.intern ("_NET_WM_STRUT_PARTIAL", false),
                             Gdk.Atom.intern ("CARDINAL", false), 32, Gdk.PropMode.REPLACE, (uint8[])struts, 12);
    }

    bool no_monitor_to_left (GLib.List <Gdk.Rectangle?> other_rects) {
        if (monitor_x == 0) {
            return true;
        }

        var panel_start = monitor_y;
        var panel_end = monitor_y + panel_height - 1;

        foreach (var rect in other_rects) {
            var end_x = rect.x + rect.width - 1;
            if (monitor_x > end_x) {
                var end_y = rect.y + rect.height - 1;
                if (panel_end >= rect.y && panel_start <= end_y) {
                    return false;
                }
            }
        }

        return true;
    }

    bool no_monitor_to_right (GLib.List <Gdk.Rectangle?> other_rects, int screen_width) {
        var monitor_end_x = monitor_x + monitor_width - 1;

        if (monitor_end_x == screen_width - 1) {
            return true;
        }

        var panel_start = monitor_y;
        var panel_end = monitor_y + panel_height - 1;

        foreach (var rect in other_rects) {
            if (monitor_end_x < (rect.x + rect.width - 1)) {
                var end_y = rect.y + rect.height - 1;
                if (panel_end >= rect.y && panel_start <= end_y) {
                    return false;
                }
            }
        }

        return true;
    }

    bool no_other_monitor_above (GLib.List <Gdk.Rectangle?> other_rects) {
        if (monitor_y == 0) {
            return true;
        }

        var monitor_end_x = monitor_x + monitor_width - 1;
        foreach (var rect in other_rects) {
            var end_y = rect.y + rect.height - 1;
            if (end_y > monitor_y) {
                var end_x = rect.x + rect.width - 1;
                if (monitor_x <= end_x && monitor_end_x >= rect.x) {
                    return false;
                }
            }
        }

        return true;
    }

    void set_struts_from_left (long *struts) {
        var scale_factor = this.get_scale_factor ();
        struts [0] = (monitor_x + monitor_width) * scale_factor;
        struts [4] = monitor_y * scale_factor;
        struts [5] = (monitor_y - panel_displacement) * scale_factor - 1;
    }

    void set_struts_from_right (long *struts, int screen_width) {
        var scale_factor = this.get_scale_factor ();
        struts [1] = (screen_width - monitor_x) * scale_factor;
        struts [6] = monitor_y * scale_factor;
        struts [7] = (monitor_y - panel_displacement) * scale_factor - 1;
    }

    void set_struts_from_top (long *struts) {
        var scale_factor = this.get_scale_factor ();
        struts [2] = (monitor_y - panel_displacement) * scale_factor;
        struts [8] = monitor_x * scale_factor;
        struts [9] = (monitor_x + monitor_width) * scale_factor - 1;
    }

    public void set_expanded (bool expand) {
        if (expand && !this.expanded) {
            Services.BackgroundManager.get_default ().remember_window ();

            this.expanded = true;
            this.set_size_request (monitor_width, monitor_height);
        } else if (!expand) {
            Services.BackgroundManager.get_default ().restore_window ();

            this.expanded = false;
            this.set_size_request (monitor_width, expanded ? monitor_height : -1);
            this.resize (monitor_width, expanded ? monitor_height : 1);
        }
    }
}

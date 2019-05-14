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
    private int panel_displacement = -1;

    private uint timeout;
    private uint delay_timeout = 0U;
    private bool hiding = false;
    private bool hovering = false;

    private bool current_maximized = false;
    private bool current_minimized = false;

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
        application.add_accelerator ("<Control>Tab", "app.cycle", null);
        application.add_accelerator ("<Control><Shift>Tab", "app.cycle-back", null);

        var background_manager = Services.BackgroundManager.get_default ();
        background_manager.active_window_changed.connect (on_active_window_changed);

        Services.PanelSettings.get_default ().notify["autohide"].connect (() => background_manager.request_active_update ());

        add (panel);
    }

    public override bool leave_notify_event (Gdk.EventCrossing event) {
        bool handled = false;
        switch (Services.PanelSettings.get_default ().autohide) {
            case DODGE_FLOAT:
                if (current_maximized) {
                    hide_panel (false);
                }
                
                handled = true;
                break;
            case FLOAT:
                hide_panel (false);
                handled = true;
                break;
        }

        hovering = false;
        return handled;
    }

    public override bool enter_notify_event (Gdk.EventCrossing event) {
        remove_id (ref delay_timeout);

        hovering = true;
        show_panel ();
        return true;
    }

    private static void remove_id (ref uint id) {
        if (id > 0U) {
            Source.remove (id);
            id = 0U;
        }
    }

    private void queue_animation (uint duration) {
        timeout = Timeout.add (duration / panel_height, animation_step);
    }

    private bool animation_step () {
        if (hiding) {
            if (popover_manager.current_indicator != null) {
                timeout = 0;
                return false;
            }

            if (panel_displacement == -1) {
                timeout = 0;
                update_struts ();
                return false;
            }

            panel_displacement++;
        } else {
            if (panel_displacement == panel_height * -1) {
                timeout = 0;
                if (Services.PanelSettings.get_default ().autohide == NONE) {
                    update_struts ();
                }

                return false;
            }

            panel_displacement--;
        }

        update_panel_dimensions ();
        return true;
    }

    private void on_realize () {
        update_panel_dimensions ();

        Services.BackgroundManager.initialize (this.monitor_number, panel_height);
    }

    private bool show_panel () {
        stop_animation ();
        hiding = false;
        if (Services.PanelSettings.get_default ().autohide != NONE) {
            start_animation ();
        } else {
            delay_timeout = 0U;
            queue_animation (300);
        }
        
        return true;
    }

    private bool hide_panel (bool window_update) {
        /**
         * Do not hide if the active window was updated
         * while the user was hovering on the panel.
         */
        if (window_update && hovering) {
            return false;
        }

        stop_animation ();
        hiding = true;
        start_animation ();

        return true;
    }

    private void start_animation () {
        if (hovering) {
            delay_timeout = Timeout.add (Services.PanelSettings.get_default ().delay, () => {
                delay_timeout = 0U;
                queue_animation (100);
                return false;
            });
        } else {
            delay_timeout = 0U;
            queue_animation (100);
        }
    }

    private void stop_animation () {
        remove_id (ref delay_timeout);
        remove_id (ref timeout);
    }

    private void on_active_window_changed (bool maximized, bool minimized) {
        current_maximized = maximized;
        current_minimized = minimized;

        if (current_minimized) {
            switch (Services.PanelSettings.get_default ().autohide) {
                case FLOAT:
                    hide_panel (true);
                    break;
                case DODGE_FLOAT:
                default:
                    show_panel ();
                    break;
            }
        } else {
            switch (Services.PanelSettings.get_default ().autohide) {
                case FLOAT:
                    hide_panel (true);
                    break;
                case DODGE_FLOAT:
                    if (current_maximized && popover_manager.current_indicator == null) {
                        hide_panel (true);
                    } else {
                        show_panel ();
                    }

                    break;
                default:
                    show_panel ();
                    break;
            }
        }
    }

    private void update_panel_dimensions () {
        panel_height = panel.get_allocated_height ();

        monitor_number = screen.get_primary_monitor ();
        Gdk.Rectangle monitor_dimensions;
        this.screen.get_monitor_geometry (monitor_number, out monitor_dimensions);

        monitor_width = monitor_dimensions.width;
        monitor_height = monitor_dimensions.height;

        this.set_size_request (monitor_width, (popover_manager.current_indicator != null ? monitor_height : -1));

        monitor_x = monitor_dimensions.x;
        monitor_y = monitor_dimensions.y;

        int wx, wy;
        get_position (out wx, out wy);

        /**
         * Instead of constantly moving the window for the animation,
         * we will only move the window when it has been hidden / shown
         * The actual animation is handed off to the panel widget.
         */
        if (panel_displacement == -1) {
            int y = monitor_y - (panel_height + panel_displacement);
            if (wx != monitor_x || wy != y) {
                move (monitor_x, y);
            }

            panel.draw_y = 0;
        } else {
            if (wx != 0 || wy != 0) {
                move (0, 0);
            }

            panel.draw_y = monitor_y - (panel_height + panel_displacement);
        }
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

        var monitor = monitor_number == -1 ? this.screen.get_primary_monitor () : monitor_number;
        var position_top = monitor_y - panel_displacement;
        var scale_factor = this.get_scale_factor ();

        Gdk.Atom atom;
        Gdk.Rectangle primary_monitor_rect;

        long struts[12];

        this.screen.get_monitor_geometry (monitor, out primary_monitor_rect);

		// We need to manually include the scale factor here as GTK gives us unscaled sizes for widgets
        struts = { 0, 0, position_top * scale_factor, 0, /* strut-left, strut-right, strut-top, strut-bottom */
                   0, 0, /* strut-left-start-y, strut-left-end-y */
                   0, 0, /* strut-right-start-y, strut-right-end-y */
                   monitor_x, ((monitor_x + monitor_width) * scale_factor) - 1, /* strut-top-start-x, strut-top-end-x */
                   0, 0 }; /* strut-bottom-start-x, strut-bottom-end-x */

        atom = Gdk.Atom.intern ("_NET_WM_STRUT_PARTIAL", false);

        Gdk.property_change (this.get_window (), atom, Gdk.Atom.intern ("CARDINAL", false),
                             32, Gdk.PropMode.REPLACE, (uint8[])struts, 12);
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

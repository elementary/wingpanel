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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
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

    private bool hidden = false;
    private bool hovering = false;

    private int panel_displacement;

    private uint shrink_timeout = 0;
    private uint animation_timeout_id = 0;
    private uint hide_timeout_id = 0;

    public PanelWindow (Gtk.Application app) {
        monitor_number = screen.get_primary_monitor ();

        this.set_application (app);

        this.decorated = false;
        this.resizable = false;
        this.skip_taskbar_hint = true;
        this.app_paintable = true;
        this.type_hint = Gdk.WindowTypeHint.DOCK;
        this.vexpand = false;

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

        this.add (panel);
    }

    public override bool enter_notify_event (Gdk.EventCrossing event) {
        if (hide_timeout_id > 0) {
            Source.remove (hide_timeout_id);
            hide_timeout_id = 0;
        }

        hovering = true;
        show_panel ();
        return true;
    }

    public override bool leave_notify_event (Gdk.EventCrossing event) {
        if ((bool) event.send_event) {
            return Gdk.EVENT_PROPAGATE;
        }

        hide_timeout_id = Timeout.add (200, () => {
            hide_timeout_id = 0;

            if (check_pointer_in_window ()) {
                return GLib.Source.REMOVE;
            }
            
            hide_panel ();
            return GLib.Source.REMOVE;
        });

        return Gdk.EVENT_PROPAGATE;
    }

    private bool animation_step () {
        if (panel_displacement <= panel_height * (-1)) {
            animation_timeout_id = 0;
            update_panel_dimensions ();
            return false;
        }

        panel_displacement--;

        update_panel_dimensions ();

        return true;
    }

    private bool animation_step_hide () {
        if (panel_displacement >= -1) {
            opacity = 0;
            animation_timeout_id = 0;
            hovering = false;
            hidden = true;

            update_panel_dimensions ();
            return GLib.Source.REMOVE;
        }

        panel_displacement++;

        update_panel_dimensions ();

        return GLib.Source.CONTINUE;
    }

    private void show_panel () {
        if (animation_timeout_id > 0) {
            Source.remove (animation_timeout_id);
            animation_timeout_id = 0;
        }

        opacity = 1;
        hidden = false;
        animation_timeout_id = Gdk.threads_add_timeout (210 / panel_height, animation_step);
    }

    private void hide_panel () {
        if (hidden || Services.BackgroundManager.get_default ().current_state != Services.BackgroundState.MAXIMIZED) {
            return;
        }

        if (animation_timeout_id > 0) {
            Source.remove (animation_timeout_id);
            animation_timeout_id = 0;
        }

        animation_timeout_id = Gdk.threads_add_timeout (210 / panel_height, animation_step_hide);
    }

    private bool check_pointer_in_window () {
        int x, y;
        get_display ().get_device_manager ().get_client_pointer ().get_position (null, out x, out y);

        int win_x_root, win_y_root;
        get_position (out win_x_root, out win_y_root);

        int win_width, win_height;
        get_size (out win_width, out win_height);

        return (
            x <= win_x_root + win_width &&
            x >= win_x_root &&
            y <= win_y_root + win_height &&
            y >= win_y_root);
    }

    private void on_realize () {
        update_panel_dimensions ();

        var bg_manager = Services.BackgroundManager.get_default ();
        bg_manager.initialize (this.monitor_number, panel_height);
        bg_manager.background_state_changed.connect (on_background_state_changed);

        show_panel ();
    }

    private void on_background_state_changed (Services.BackgroundState state, uint animation_duration) {
        switch (state) {
            case Services.BackgroundState.MAXIMIZED:
                hide_panel ();
                break;
            default:
                if (hidden) {
                    show_panel ();
                }
                break;
        }
    }

    private void update_panel_dimensions () {
        panel_height = panel.get_allocated_height ();

        monitor_number = screen.get_primary_monitor ();
        Gdk.Rectangle monitor_dimensions;
        this.screen.get_monitor_geometry (monitor_number, out monitor_dimensions);

        monitor_width = monitor_dimensions.width;
        monitor_height = monitor_dimensions.height;

        this.set_size_request (monitor_width, (popover_manager.current_indicator != null ? monitor_height : 30));

        monitor_x = monitor_dimensions.x;
        monitor_y = monitor_dimensions.y;

        this.move (monitor_x, monitor_y - (panel_height + panel_displacement));

        if (!hovering) {
            Gdk.threads_add_idle (() => {
                update_struts ();
                return false;
            });
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

        var position_top = hidden ? monitor_y : monitor_y - panel_displacement;

        Gdk.Atom atom;
        long struts[12];

		// We need to manually include the scale factor here as GTK gives us unscaled sizes for widgets
        struts = { 0, 0, position_top * this.get_scale_factor () , 0, /* strut-left, strut-right, strut-top, strut-bottom */
                   0, 0, /* strut-left-start-y, strut-left-end-y */
                   0, 0, /* strut-right-start-y, strut-right-end-y */
                   monitor_x, monitor_x + monitor_width - 1, /* strut-top-start-x, strut-top-end-x */
                   0, 0 }; /* strut-bottom-start-x, strut-bottom-end-x */

        atom = Gdk.Atom.intern ("_NET_WM_STRUT_PARTIAL", false);

        Gdk.property_change (this.get_window (), atom, Gdk.Atom.intern ("CARDINAL", false),
                             32, Gdk.PropMode.REPLACE, (uint8[])struts, 12);
    }

    public void set_expanded (bool expand) {
        if (expand && !this.expanded) {
            Services.BackgroundManager.get_default ().remember_window ();

            this.expanded = true;

            if (shrink_timeout > 0) {
                Source.remove (shrink_timeout);
                shrink_timeout = 0;
            }

            this.set_size_request (monitor_width, monitor_height);
        } else if (!expand) {
            Services.BackgroundManager.get_default ().restore_window ();

            this.expanded = false;

            if (shrink_timeout > 0) {
                Source.remove (shrink_timeout);
            }

            shrink_timeout = Timeout.add (300, () => {
                shrink_timeout = 0;
                this.set_size_request (monitor_width, expanded ? monitor_height : -1);
                this.resize (monitor_width, expanded ? monitor_height : 1);
                return false;
            });
        }
    }
}

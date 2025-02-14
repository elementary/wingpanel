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
    private int panel_height;

    private Pantheon.Desktop.Shell? desktop_shell;
    private Pantheon.Desktop.Panel? desktop_panel;

    public PanelWindow (Gtk.Application application) {
        Object (
            application: application,
            decorated: false,
            resizable: false,
            vexpand: false
        );

        var app_provider = new Gtk.CssProvider ();
        app_provider.load_from_resource ("io/elementary/wingpanel/Application.css");
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (), app_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        popover_manager = new Services.PopoverManager ();

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

        child = panel;
        remove_css_class (Granite.STYLE_CLASS_BACKGROUND);

        popover_manager.notify["indicator-open"].connect (() => {
            if (!popover_manager.indicator_open) {
                Services.BackgroundManager.get_default ().restore_window ();
                return;
            } else {
                Services.BackgroundManager.get_default ().remember_window ();
            }

            if (desktop_panel != null) {
                desktop_panel.focus ();
            } else if (Gdk.Display.get_default () is Gdk.X11.Display) {
                var display = (Gdk.X11.Display) Gdk.Display.get_default ();
                var surface = (Gdk.X11.Surface) get_surface ();

                display.get_xdisplay ().set_input_focus (surface.get_xid (), 0, 0);
            }
        });

        var key_controller = new Gtk.EventControllerKey ();
        ((Gtk.Widget) this).add_controller (key_controller);
        key_controller.key_pressed.connect (on_key_pressed);
    }

    private void on_realize () {
        update_panel_dimensions ();
        Services.BackgroundManager.initialize (panel_height);

        if (Gdk.Display.get_default () is Gdk.Wayland.Display) {
            init_wl ();
        } else {
            init_x ();
        }
    }

    private void update_panel_dimensions () {
        panel_height = panel.get_allocated_height ();

        // We just use our monitor because Gala makes sure we are always on the primary one
        var monitor_dimensions = get_display ().get_monitor_at_surface (get_surface ()).get_geometry ();

        if (!Services.DisplayConfig.is_logical_layout () && Gdk.Display.get_default () is Gdk.Wayland.Display) {
            monitor_dimensions.width /= get_scale_factor ();
            monitor_dimensions.height /= get_scale_factor ();
            monitor_dimensions.x /= get_scale_factor ();
            monitor_dimensions.y /= get_scale_factor ();
        }

        this.set_size_request (monitor_dimensions.width, -1);
    }

    private bool on_key_pressed (uint keyval, uint keycode, Gdk.ModifierType state) {
        if (keyval == Gdk.Key.Escape) {
            popover_manager.close ();
        }

        return Gdk.EVENT_PROPAGATE;
    }

    public void toggle_indicator (string name) {
        popover_manager.toggle_popover_visible (name);
    }

    private void init_x () {
        var display = Gdk.Display.get_default ();
        if (display is Gdk.X11.Display) {
            unowned var xdisplay = ((Gdk.X11.Display) display).get_xdisplay ();

            var window = ((Gdk.X11.Surface) get_surface ()).get_xid ();

            var prop = xdisplay.intern_atom ("_MUTTER_HINTS", false);

            var value = "anchor=4:hide-mode=0";

            xdisplay.change_property (window, prop, X.XA_STRING, 8, 0, (uchar[]) value, value.length);

            Idle.add_once (update_panel_dimensions); // Update again since we now can be 100% sure that we are on the primary monitor
        }
    }

    public void registry_handle_global (Wl.Registry wl_registry, uint32 name, string @interface, uint32 version) {
        if (@interface == "io_elementary_pantheon_shell_v1") {
            desktop_shell = wl_registry.bind<Pantheon.Desktop.Shell> (name, ref Pantheon.Desktop.Shell.iface, uint32.min (version, 1));
            unowned var window = get_surface ();
            if (window is Gdk.Wayland.Surface) {
                unowned var wl_surface = ((Gdk.Wayland.Surface) window).get_wl_surface ();
                desktop_panel = desktop_shell.get_panel (wl_surface);
                desktop_panel.set_anchor (TOP);
                desktop_panel.set_hide_mode (NEVER);

                Idle.add_once (update_panel_dimensions); // Update again since we now can be 100% sure that we are on the primary monitor
            }
        }
    }

    private static Wl.RegistryListener registry_listener;
    private void init_wl () {
        registry_listener.global = registry_handle_global;
        unowned var display = Gdk.Display.get_default ();
        if (display is Gdk.Wayland.Display) {
            unowned var wl_display = ((Gdk.Wayland.Display) display).get_wl_display ();
            var wl_registry = wl_display.get_registry ();
            wl_registry.add_listener (
                registry_listener,
                this
            );

            if (wl_display.roundtrip () < 0) {
                return;
            }
        }
    }
}

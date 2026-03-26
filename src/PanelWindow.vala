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

    private Gtk.CssProvider? style_provider = null;

    public PanelWindow (Gtk.Application application) {
        Object (
            application: application,
            decorated: false,
            resizable: false,
            vexpand: false
        );

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
        });

        notify["scale-factor"].connect (update_panel_dimensions);
    }

    construct {
        Services.BackgroundManager.get_default ().background_state_changed.connect (update_background);
    }

    private void on_realize () {
        ((Gdk.Toplevel) get_surface ()).compute_size.connect (on_compute_size);

        update_panel_dimensions ();
        Services.BackgroundManager.initialize (panel_height);

        init_wl ();
    }

    private void on_compute_size (Gdk.ToplevelSize top_level_size) {
        /* We do our own size calculation to make sure the box shadow in the translucent style isn't cut off */
        top_level_size.set_size (width_request, panel.get_height () + 5);
        top_level_size.set_shadow_width (0, 0, 0, 5);
    }

    private void update_panel_dimensions () {
        panel_height = panel.get_height ();

        // We just use our monitor because Gala makes sure we are always on the primary one
        var monitor_dimensions = get_display ().get_monitor_at_surface (get_surface ()).get_geometry ();

        if (!Services.DisplayConfig.is_logical_layout ()) {
            monitor_dimensions.width /= get_scale_factor ();
            monitor_dimensions.height /= get_scale_factor ();
            monitor_dimensions.x /= get_scale_factor ();
            monitor_dimensions.y /= get_scale_factor ();
        }

        this.set_size_request (monitor_dimensions.width, -1);
    }

    public void toggle_indicator (string name) {
        popover_manager.toggle_popover_visible (name);
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
                panel.css_classes = {"color-light"};
                break;
            case Services.BackgroundState.LIGHT:
                panel.css_classes = {"color-dark"};
                break;
            case Services.BackgroundState.MAXIMIZED:
                panel.css_classes = {"maximized"};
                break;
            case Services.BackgroundState.TRANSLUCENT_DARK:
                panel.css_classes = {
                    "color-light",
                    "translucent"
                };
                break;
            case Services.BackgroundState.TRANSLUCENT_LIGHT:
                panel.css_classes = {
                    "color-dark",
                    "translucent"
                };
                break;
        }


        if (desktop_panel == null) {
            return;
        }

        switch (state) {
            case Services.BackgroundState.DARK :
            case Services.BackgroundState.LIGHT:
            case Services.BackgroundState.MAXIMIZED:
                desktop_panel.remove_blur ();
                break;
            case Services.BackgroundState.TRANSLUCENT_DARK:
            case Services.BackgroundState.TRANSLUCENT_LIGHT:
                desktop_panel.add_blur (0, 0, 0, 4, 0);
                break;
        }
    }
}

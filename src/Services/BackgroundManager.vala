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

namespace Wingpanel.Services {
    public enum BackgroundState {
        LIGHT,
        DARK,
        MAXIMIZED,
        TRANSLUCENT_DARK,
        TRANSLUCENT_LIGHT
    }

    [DBus (name = "org.pantheon.gala.WingpanelInterface")]
    public interface WingpanelInterfaceBus : Object {
        public abstract void initialize () throws GLib.Error;
        public abstract void remember_focused_window () throws GLib.Error;
        public abstract void restore_focused_window () throws GLib.Error;
        public abstract bool begin_grab_focused_window (int x, int y, int button, uint time, uint state) throws GLib.Error;
    }

    [DBus (name = "io.elementary.gala.BackgroundStateManager")]
    public interface BackgroundStateManagerBus : Object {
        public signal void state_changed (BackgroundState state, uint animation_duration);

        public abstract void initialize (int panel_height) throws GLib.Error;
    }

    public class BackgroundManager : Object {
        private const string WINGPANEL_INTERFACE_DBUS_NAME = "org.pantheon.gala.WingpanelInterface";
        private const string WINGPANEL_INTERFACE_DBUS_PATH = "/org/pantheon/gala/WingpanelInterface";
        private const string BG_STATE_MANAGER_DBUS_NAME = "io.elementary.gala.BackgroundStateManager";
        private const string BG_STATE_MANAGER_DBUS_PATH = "/io/elementary/gala/BackgroundStateManager";

        private static BackgroundManager? instance = null;
        private static int panel_height;

        private WingpanelInterfaceBus? wingpanel_interface = null;
        private BackgroundStateManagerBus? bg_state_manager = null;

        private BackgroundState current_state = BackgroundState.LIGHT;
        private bool use_transparency = true;

        public signal void background_state_changed (BackgroundState state, uint animation_duration);

        public static void initialize (int panel_height) {
            BackgroundManager.panel_height = panel_height;
        }

        private BackgroundManager () {
            var panel_settings = new GLib.Settings ("io.elementary.desktop.wingpanel");

            panel_settings.changed["use-transparency"].connect (() => {
                use_transparency = panel_settings.get_boolean ("use-transparency");
                state_updated ();
            });

            use_transparency = panel_settings.get_boolean ("use-transparency");

            Bus.watch_name (BusType.SESSION, WINGPANEL_INTERFACE_DBUS_NAME, BusNameWatcherFlags.NONE,
                connect_wingpanel_interface,
                () => {
                    wingpanel_interface = null;
                }
            );

            Bus.watch_name (BusType.SESSION, BG_STATE_MANAGER_DBUS_NAME, BusNameWatcherFlags.NONE,
                connect_bg_state_manager,
                () => {
                    bg_state_manager = null;
                    // If the Gala bus is unavailable or vanishes, fall back to maximized style,
                    // as this is most visible on all backgrounds
                    background_state_changed (BackgroundState.MAXIMIZED, 0);
                }
            );

        }

        public void remember_window () {
            if (wingpanel_interface == null) {
                return;
            }

            try {
                wingpanel_interface.remember_focused_window ();
            } catch (Error e) {
                warning ("Remembering focused window failed: %s", e.message);
            }
        }

        public void restore_window () {
            if (wingpanel_interface == null) {
                return;
            }

            try {
                wingpanel_interface.restore_focused_window ();
            } catch (Error e) {
                warning ("Restoring last focused window failed: %s", e.message);
            }
        }

        public bool begin_grab_focused_window (int x, int y, int button, uint time, uint state) {
            if (wingpanel_interface == null) {
                return false;
            }

            try {
                return wingpanel_interface.begin_grab_focused_window (x, y, button, time, state);
            } catch (Error e) {
                warning ("Grabbing focused window failed: %s", e.message);
            }

            return false;
        }

        private void connect_wingpanel_interface () {
            try {
                wingpanel_interface = Bus.get_proxy_sync (
                    BusType.SESSION,
                    WINGPANEL_INTERFACE_DBUS_NAME,
                    WINGPANEL_INTERFACE_DBUS_PATH
                );
                wingpanel_interface.initialize ();
            } catch (Error e) {
                warning ("Connecting to \"%s\" failed: %s", WINGPANEL_INTERFACE_DBUS_NAME, e.message);
            }
        }

        private void connect_bg_state_manager () {
            try {
                bg_state_manager = Bus.get_proxy_sync (
                    BusType.SESSION,
                    BG_STATE_MANAGER_DBUS_NAME,
                    BG_STATE_MANAGER_DBUS_PATH
                );
                bg_state_manager.initialize (panel_height);
            } catch (Error e) {
                warning ("Connecting to \"%s\" failed: %s", BG_STATE_MANAGER_DBUS_NAME, e.message);
                return;
            }

            bg_state_manager.state_changed.connect ((state, animation_duration) => {
                current_state = state;
                state_updated (animation_duration);
            });

            state_updated ();
        }

        private void state_updated (uint animation_duration = 0) {
            background_state_changed (use_transparency ? current_state : BackgroundState.MAXIMIZED, animation_duration);
        }

        public static BackgroundManager get_default () {
            if (instance == null) {
                instance = new BackgroundManager ();
            }

            return instance;
        }
    }
}

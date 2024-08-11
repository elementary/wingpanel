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
    public interface InterfaceBus : Object {
        public signal void state_changed (BackgroundState state, uint animation_duration);

        public abstract void initialize (int panel_height) throws GLib.Error;
        public abstract void remember_focused_window () throws GLib.Error;
        public abstract void restore_focused_window () throws GLib.Error;
        public abstract bool begin_grab_focused_window (int x, int y, int button, uint time, uint state) throws GLib.Error;
    }

    public class BackgroundManager : Object {
        private const string DBUS_NAME = "org.pantheon.gala.WingpanelInterface";
        private const string DBUS_PATH = "/org/pantheon/gala/WingpanelInterface";

        private static BackgroundManager? instance = null;

        private InterfaceBus? bus = null;

        private BackgroundState current_state = BackgroundState.LIGHT;
        private bool use_transparency = true;

        private bool bus_available {
            get {
                return bus != null;
            }
        }

        private int panel_height;

        public signal void background_state_changed (BackgroundState state, uint animation_duration);

        public static void initialize (int panel_height) {
            var manager = BackgroundManager.get_default ();
            manager.panel_height = panel_height;
        }

        private BackgroundManager () {
            var panel_settings = new GLib.Settings ("io.elementary.desktop.wingpanel");

            panel_settings.changed["use-transparency"].connect (() => {
                use_transparency = panel_settings.get_boolean ("use-transparency");
                state_updated ();
            });

            use_transparency = panel_settings.get_boolean ("use-transparency");

            Bus.watch_name (BusType.SESSION, DBUS_NAME, BusNameWatcherFlags.NONE,
                () => connect_dbus (),
                () => {
                    bus = null;
                    // If the Gala bus is unavailable or vanishes, fall back to maximized style,
                    // as this is most visible on all backgrounds
                    background_state_changed (BackgroundState.MAXIMIZED, 0);
                });
        }

        public void remember_window () {
            if (!bus_available) {
                return;
            }

            try {
                bus.remember_focused_window ();
            } catch (Error e) {
                warning ("Remembering focused window failed: %s", e.message);
            }
        }

        public void restore_window () {
            if (!bus_available) {
                return;
            }

            try {
                bus.restore_focused_window ();
            } catch (Error e) {
                warning ("Restoring last focused window failed: %s", e.message);
            }
        }

        public bool begin_grab_focused_window (int x, int y, int button, uint time, uint state) {
            try {
                return bus.begin_grab_focused_window (x, y, button, time, state);
            } catch (Error e) {
                warning ("Grabbing focused window failed: %s", e.message);
            }

            return false;
        }

        private bool connect_dbus () {
            try {
                bus = Bus.get_proxy_sync (BusType.SESSION, DBUS_NAME, DBUS_PATH);
                bus.initialize (panel_height);
            } catch (Error e) {
                warning ("Connecting to \"%s\" failed: %s", DBUS_NAME, e.message);
                return false;
            }

            bus.state_changed.connect ((state, animation_duration) => {
                current_state = state;
                state_updated (animation_duration);
            });

            state_updated ();
            return true;
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

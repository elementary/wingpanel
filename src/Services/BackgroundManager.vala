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

namespace Wingpanel.Services {
    public enum BackgroundState {
        LIGHT,
        DARK,
        MAXIMIZED,
        TRANSLUCENT
    }

    [DBus (name = "org.pantheon.gala.WingpanelInterface")]
    public interface InterfaceBus : Object {
        public signal void state_changed (BackgroundState state, uint animation_duration);

        public abstract void initialize (int monitor, int panel_height) throws IOError;
        public abstract void remember_focused_window () throws IOError;
        public abstract void restore_focused_window () throws IOError;
    }

    public class BackgroundManager : Object {
        private const string DBUS_NAME = "org.pantheon.gala.WingpanelInterface";
        private const string DBUS_PATH = "/org/pantheon/gala/WingpanelInterface";

        private static BackgroundManager? instance = null;

        private InterfaceBus bus;

        private BackgroundState current_state = BackgroundState.LIGHT;
        private bool use_transparency = true;

        public signal void background_state_changed (BackgroundState state, uint animation_duration);

        public BackgroundManager () {
            if (!connect_dbus ()) {
                return;
            }

            PanelSettings.get_default ().notify["use-transparency"].connect (() => {
                use_transparency = PanelSettings.get_default ().use_transparency;
                state_updated ();
            });

            use_transparency = PanelSettings.get_default ().use_transparency;
            state_updated ();
        }

        public void initialize (int monitor, int panel_height) {
            try {
                bus.initialize (monitor, panel_height);
            } catch (Error e) {
                warning ("Initializing background manager failed: %s", e.message);
            }

            bus.state_changed.connect ((state, animation_duration) => {
                current_state = state;
                state_updated (animation_duration);
            });
        }

        public void remember_window () {
            try {
                bus.remember_focused_window ();
            } catch (Error e) {
                warning ("Remembering focused window failed: %s", e.message);
            }
        }

        public void restore_window () {
            try {
                bus.restore_focused_window ();
            } catch (Error e) {
                warning ("Restoring last focused window failed: %s", e.message);
            }
        }

        private bool connect_dbus () {
            try {
                bus = Bus.get_proxy_sync (BusType.SESSION, DBUS_NAME, DBUS_PATH);
            } catch (Error e) {
                warning ("Connecting to \"%s\" failed: %s", DBUS_NAME, e.message);

                return false;
            }

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

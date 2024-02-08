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

/*
 *   This plugin adds a dbus-interface to gala that provides additional information
 *   about windows and workspaces for the panel.
 */

public class WingpanelInterface.Main : Gala.Plugin {
    private const string DBUS_NAME = "org.pantheon.gala.WingpanelInterface";
    private const string DBUS_PATH = "/org/pantheon/gala/WingpanelInterface";

    public static Gala.WindowManager wm;
    public static unowned Meta.Display display;

    private DBusConnection? dbus_connection = null;

    public override void initialize (Gala.WindowManager _wm) {
        if (_wm == null) {
            return;
        }

        wm = _wm;
        display = wm.get_display ();

        Bus.own_name (BusType.SESSION,
                      DBUS_NAME,
                      BusNameOwnerFlags.NONE,
                      on_bus_aquired,
                      null,
                      () => warning ("Acquiring \"%s\" failed.", DBUS_NAME));
    }

    public override void destroy () {
        try {
            if (dbus_connection != null) {
                dbus_connection.close_sync ();
            }
        } catch (Error e) {
            warning ("Closing DBus service failed: %s", e.message);
        }
    }

    private void on_bus_aquired (DBusConnection connection) {
        dbus_connection = connection;

        try {
            var server = new DBusServer ();

            dbus_connection.register_object (DBUS_PATH, server);

            debug ("DBus service registered.");
        } catch (Error e) {
            warning ("Registering DBus service failed: %s", e.message);
        }
    }
}

public Gala.PluginInfo register_plugin () {
    return {
               "wingpanel-interface",
               "Wingpanel Developers",
               typeof (WingpanelInterface.Main),
               Gala.PluginFunction.ADDITION,
               Gala.LoadPriority.IMMEDIATE
    };
}

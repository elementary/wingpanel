/*
 * Copyright (c) 2019 Wingpanel Developers (http://github.com/elementary/wingpanel)
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

[DBus (name = "org.pantheon.gala.plugins.notify")]
public interface INotifyPlugin : Object { 
    public abstract void set_stack_y_offset (int offset) throws Error;
}

public class Wingpanel.Services.NotifyPluginClient : Object {
    private INotifyPlugin? bus;

    private const string DBUS_NAME = "org.pantheon.gala.plugins.notify";
    private const string DBUS_PATH = "/org/pantheon/gala/plugins/notify";

    construct {
        Bus.watch_name (BusType.SESSION, DBUS_NAME, BusNameWatcherFlags.NONE,
                () => connect_dbus (),
                () => bus = null);
    }

    public void set_stack_y_offset (int offset) {
        if (bus != null) {
            try {
                bus.set_stack_y_offset (offset);
            } catch (Error e) {
                warning (e.message);
            }
        }
    }

    private void connect_dbus () {
        try {
            bus = Bus.get_proxy_sync (BusType.SESSION, DBUS_NAME, DBUS_PATH);
        } catch (Error e) {
            warning ("Connecting to \"%s\" failed: %s", DBUS_NAME, e.message);
        }
    }
}
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

[DBus (name = "org.pantheon.gala.WingpanelInterface")]
public class WingpanelInterface.DBusServer : Object {
    private BackgroundManager background_manager;

    public signal void state_changed (BackgroundState state, uint animation_duration);

    public void initialize (int monitor, int panel_height) {
        background_manager = new BackgroundManager (monitor, panel_height);
        background_manager.state_changed.connect ((state, animation_duration) => {
            state_changed (state, animation_duration);
        });
    }

    public bool begin_grab_focused_window (int x, int y, int button, uint time, uint state) {
        return FocusManager.get_default ().begin_grab_focused_window (x, y, button, time, state);
    }

    public void remember_focused_window () {
        FocusManager.get_default ().remember_focused_window ();
    }

    public void restore_focused_window () {
        FocusManager.get_default ().restore_focused_window ();
    }
}

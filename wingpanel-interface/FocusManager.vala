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

public class WingpanelInterface.FocusManager : Object {
    private static FocusManager? instance = null;

    private Meta.Workspace? current_workspace = null;
    private Meta.Window? last_focused_window = null;

    public FocusManager () {
        Main.screen.workspace_switched.connect (() => {
            update_current_workspace ();
        });

        update_current_workspace ();
    }

    public void remember_focused_window () {
        var windows = current_workspace.list_windows ();

        foreach (Meta.Window window in windows) {
            if (window.has_focus ()) {
                last_focused_window = window;

                return;
            }
        }
    }

    public void restore_focused_window () {
        if (last_focused_window != null) {
            var display = Main.screen.get_display ();
            last_focused_window.focus (display.get_current_time ());
        }
    }

    public bool begin_grab_focused_window (int x, int y, int button, uint time, uint state) {
        var display = Main.screen.get_display ();
        var window = display.get_focus_window ();
        if (window == null || !get_can_grab_window (window, x, y)) {
            unowned Meta.Workspace workspace = Main.screen.get_active_workspace ();
            List<unowned Meta.Window>? windows = workspace.list_windows ();
            if (windows == null) {
                return false;
            }

            window = null;
            List<unowned Meta.Window> copy = windows.copy ();
            copy.reverse ();
            copy.@foreach ((win) => {
                if (window != null) {
                    return;
                }

                if (get_can_grab_window (win, x, y)) {
                    window = win;
                }
            });
        }

        if (window != null) {
            display.begin_grab_op (Main.screen, window, Meta.GrabOp.MOVING, false, true, button, state, time, x, y);
            return true;
        }

        return false;
    }

    private static bool get_can_grab_window (Meta.Window window, int x, int y) {
        var frame = window.get_frame_rect ();
        return !window.minimized && window.maximized_vertically && x >= frame.x && x <= frame.x + frame.width;
    }

    private void update_current_workspace () {
        var workspace = Main.screen.get_workspace_by_index (Main.screen.get_active_workspace_index ());

        if (workspace == null) {
            warning ("Cannot get active workspace");

            return;
        }

        current_workspace = workspace;
    }

    public static FocusManager get_default () {
        if (instance == null) {
            instance = new FocusManager ();
        }

        return instance;
    }
}

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

public enum BackgroundState {
    LIGHT,
    DARK,
    MAXIMIZED,
    TRANSLUCENT
}

public class WingpanelInterface.BackgroundManager : Object {
    private const int WALLPAPER_TRANSITION_DURATION = 150;
    private const double ACUTANCE_THRESHOLD = 8;
    private const double STD_THRESHOLD = 45;
    private const double LUMINANCE_THRESHOLD = 180;

    public signal void state_changed (BackgroundState state, uint animation_duration);

    public int monitor { private get; construct; }
    public int panel_height{ private get; construct; }

    private ulong wallpaper_hook_id;

    private Meta.Workspace? current_workspace = null;

    private BackgroundState current_state = BackgroundState.LIGHT;
    
    private Utils.ColorInformation? bk_color_info = null;

    public BackgroundManager (int monitor, int panel_height) {
        Object (monitor : monitor, panel_height: panel_height);

        connect_signals ();
        update_bk_color_info.begin ((obj, res) => {
            update_bk_color_info.end (res);
            update_current_workspace ();
        });
    }

    ~BackgroundManager () {
        var signal_id = GLib.Signal.lookup ("changed", Main.wm.background_group.get_type ());
        GLib.Signal.remove_emission_hook (signal_id, wallpaper_hook_id);
    }

    private void connect_signals () {
        Main.screen.workspace_switched.connect (() => {
            update_current_workspace ();
        });

        var signal_id = GLib.Signal.lookup ("changed", Main.wm.background_group.get_type ());

        wallpaper_hook_id = GLib.Signal.add_emission_hook (signal_id, 0, (ihint, param_values) => {
            update_bk_color_info.begin ((obj, res) => {
                update_bk_color_info.end (res);
                check_for_state_change (WALLPAPER_TRANSITION_DURATION);
            });

            return true;
        }, null);
    }

    private void update_current_workspace () {
        var workspace = Main.screen.get_workspace_by_index (Main.screen.get_active_workspace_index ());

        if (workspace == null) {
            warning ("Cannot get active workspace");

            return;
        }

        if (current_workspace != null) {
            current_workspace.window_added.disconnect (on_window_added);
            current_workspace.window_removed.disconnect (on_window_removed);
        }

        current_workspace = workspace;

        foreach (Meta.Window window in current_workspace.list_windows ()) {
            if (window.is_on_primary_monitor ()) {
                register_window (window);
            }
        }

        current_workspace.window_added.connect (on_window_added);
        current_workspace.window_removed.connect (on_window_removed);

        check_for_state_change (AnimationSettings.get_default ().workspace_switch_duration);
    }

    private void register_window (Meta.Window window) {
        window.notify["maximized-vertically"].connect (() => {
            check_for_state_change (AnimationSettings.get_default ().snap_duration);
        });

        window.notify["minimized"].connect (() => {
            check_for_state_change (AnimationSettings.get_default ().minimize_duration);
        });
    }

    private void on_window_added (Meta.Window window) {
        register_window (window);

        check_for_state_change (AnimationSettings.get_default ().snap_duration);
    }

    private void on_window_removed (Meta.Window window) {
        check_for_state_change (AnimationSettings.get_default ().snap_duration);
    }

    public async void update_bk_color_info () {
        SourceFunc callback = update_bk_color_info.callback;
        Gdk.Rectangle monitor_geometry;

        Gdk.Screen.get_default ().get_monitor_geometry (monitor, out monitor_geometry);

        Utils.get_background_color_information.begin (Main.wm, monitor, 0, 0, monitor_geometry.width, panel_height, (obj, res) => {
            try {
                bk_color_info = Utils.get_background_color_information.end (res);
            } catch (Error e) {
                warning (e.message);
            } finally {
                callback ();
            }
        });
        
        yield;
    }

    /**
     * Check if Wingpanel's background state should change.
     *
     * The state is defined as follows:
     *  - If there's a maximized window, the state should be MAXIMIZED;
     *  - If no information about the background could be gathered, it should be TRANSLUCENT;
     *  - If there's too much contrast or sharpness, it should be TRANSLUCENT;
     *  - If the background is too bright, it should be DARK;
     *  - Else it should be LIGHT.
     */
    private void check_for_state_change (uint animation_duration) {
        bool has_maximized_window = false;

        foreach (Meta.Window window in current_workspace.list_windows ()) {
            if (window.get_monitor () == monitor) {
                if (!window.minimized && window.maximized_vertically) {
                    has_maximized_window = true;
                    break;
                }
            }
        }

        BackgroundState new_state;

        if (has_maximized_window) {
            new_state = BackgroundState.MAXIMIZED;
        } else if (bk_color_info == null) {
            new_state = BackgroundState.TRANSLUCENT;
        } else {
            var luminance_std = Math.sqrt (bk_color_info.luminance_variance);
            
            new_state = luminance_std > STD_THRESHOLD ||
                (bk_color_info.mean_luminance < LUMINANCE_THRESHOLD &&
                    bk_color_info.mean_luminance + 1.645 * luminance_std > LUMINANCE_THRESHOLD ) || 
                bk_color_info.mean_acutance > ACUTANCE_THRESHOLD ? BackgroundState.TRANSLUCENT :
                    bk_color_info.mean_luminance > LUMINANCE_THRESHOLD ? BackgroundState.DARK : BackgroundState.LIGHT;
        }

        if (new_state != current_state) {
            state_changed (current_state = new_state, animation_duration);
        }
    }
}

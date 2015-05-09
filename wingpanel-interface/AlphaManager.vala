/*-
 * Copyright (c) 2015 Wingpanel Developers (http://launchpad.net/wingpanel)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public enum BackgroundAlpha {
	DARKEST,
	LIGHTEST
}

public class WingpanelInterface.AlphaManager : Object {
	private static AlphaManager? instance = null;

	public signal void alpha_updated (uint animation_duration);

	private Meta.Workspace? current_workspace = null;

	public AlphaManager () {
		connect_signals ();

		update_current_workspace ();
	}

	private void connect_signals () {
		Main.screen.workspace_switched.connect (() => {
			update_current_workspace ();

			alpha_updated (300); // TODO: Duration
		});
	}

	public double calculate_alpha_for_background () {
		return 0.3; // TODO: Calculate alpha using wallpaper
	}

	public BackgroundAlpha get_alpha_mode () {
		if (current_workspace == null)
			return BackgroundAlpha.LIGHTEST;

		var windows = current_workspace.list_windows ();

		foreach (Meta.Window window in windows) {
			if (window.is_on_primary_monitor ()) {
				if (window.maximized_vertically)
					return BackgroundAlpha.DARKEST;
			}
		}

		return BackgroundAlpha.LIGHTEST;
	}

	private void update_current_workspace () {
		var workspace = Main.screen.get_workspace_by_index (Main.screen.get_active_workspace_index ());

		if (workspace == null) {
			warning ("Cannot get active workspace");

			return;
		}

		if (current_workspace != null)
			current_workspace.window_added.disconnect (register_window);

		current_workspace = workspace;

		current_workspace.window_added.connect (register_window);

		foreach (Meta.Window window in current_workspace.list_windows ()) {
			if (window.is_on_primary_monitor ())
				register_window (window);
		}
	}

	private void register_window (Meta.Window window) {
		window.notify["maximized-vertically"].connect ((param) => {
			alpha_updated (300); // TODO: Duration
		});

		alpha_updated (300); // TODO: Duration
	}

	public static AlphaManager get_default () {
		if (instance == null)
			instance = new AlphaManager ();

		return instance;
	}
}

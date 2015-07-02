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

[DBus (name = "org.pantheon.gala.WingpanelInterface")]
public class WingpanelInterface.DBusServer : Object {
	public signal void alpha_changed (uint animation_duration);
	public signal void wallpaper_changed ();

	public BackgroundAlpha get_alpha (int monitor) {
		return AlphaManager.get_default ().get_alpha_mode (monitor);
	}

	public async double get_background_alpha (int monitor, int panel_height) {
		return yield AlphaManager.get_default ().calculate_alpha_for_background (monitor, panel_height);
	}

	public void remember_focused_window () {
		FocusManager.get_default ().remember_focused_window ();
	}

	public void restore_focused_window () {
		FocusManager.get_default ().restore_focused_window ();
	}
}

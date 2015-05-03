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

/*
	This plugin adds a dbus-interface to gala that provides additional information
	about windows and workspaces for the panel.
*/

public class WingpanelInterface.Main : Gala.Plugin {
	private Gala.WindowManager? wm = null;
	private Meta.Screen screen;

	public override void initialize (Gala.WindowManager wm) {
		if (wm == null)
			return;

		this.wm = wm;
		screen = wm.get_screen ();
	}

	public override void destroy () {

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


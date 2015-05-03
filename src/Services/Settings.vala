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

public class Wingpanel.Services.Settings : Granite.Services.Settings {
	// Use the namespace to avoid possible GLib conflicts
	private static Wingpanel.Services.Settings? instance = null;

	public string[] order { get; set; }
	public double min_alpha { get; set; }
	public double max_alpha { get; set; }

	public Settings () {
		base ("org.pantheon.desktop.wingpanel");
	}

	public static Wingpanel.Services.Settings get_default () {
		if (instance == null)
			instance = new Wingpanel.Services.Settings ();

		return instance;
	}
}

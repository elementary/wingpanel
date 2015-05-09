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

public class WingpanelInterface.AnimationSettings : Granite.Services.Settings {
	public bool enable_animations { get; set; }
	public int open_duration { get; set; }
	public int snap_duration { get; set; }
	public int close_duration { get; set; }
	public int minimize_duration { get; set; }
	public int workspace_switch_duration { get; set; }
	public int menu_duration { get; set; }

	static AnimationSettings? instance = null;

	private AnimationSettings () {
		base ("org.pantheon.desktop.gala.animations");
	}

	public static unowned AnimationSettings get_default () {
		if (instance == null)
			instance = new AnimationSettings ();

		return instance;
	}
}

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

	public AlphaManager () {
		Main.screen.workspace_switched.connect (() => alpha_updated (300)); // TODO: Duration
	}

	public double calculate_alpha_for_background () {
		return 0.3; // TODO: Calculate alpha using wallpaper
	}

	public BackgroundAlpha get_alpha_mode () {
		return Random.boolean () ? BackgroundAlpha.DARKEST : BackgroundAlpha.LIGHTEST;
	}

	public static AlphaManager get_default () {
		if (instance == null)
			instance = new AlphaManager ();

		return instance;
	}
}

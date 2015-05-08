/*
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

namespace Wingpanel.Services {
	public enum BackgroundAlpha {
		DARKEST,
		LIGHTEST
	}

	[DBus (name = "org.pantheon.gala.WingpanelInterface")]
	public interface InterfaceBus : Object {
		public signal void alpha_changed (uint animation_duration);

		public abstract BackgroundAlpha get_alpha () throws IOError;
		public abstract double get_background_alpha () throws IOError;
	}

	public class BackgroundManager : Object {
		private const string DBUS_NAME = "org.pantheon.gala.WingpanelInterface";
		private const string DBUS_PATH = "/org/pantheon/gala/WingpanelInterface";

		private static BackgroundManager? instance = null;

		private InterfaceBus bus;

		public signal void alpha_updated (double alpha, uint animation_duration);

		public BackgroundManager () {
			if (!connect_dbus ())
				return;

			bus.alpha_changed.connect (update_panel_alpha);

			Settings.get_default ().changed.connect (() => update_panel_alpha ());

			update_panel_alpha ();
		}

		private bool connect_dbus () {
			try {
				bus = Bus.get_proxy_sync (BusType.SESSION, DBUS_NAME, DBUS_PATH);
			} catch (Error e) {
				warning ("Connecting to \"%s\" failed: %s", DBUS_NAME, e.message);

				return false;
			}

			return true;
		}

		private void update_panel_alpha (uint animation_duration = 0) {
			try {
				double alpha_value = 0;

				if (Settings.get_default ().use_transparency) {
					var alpha = bus.get_alpha ();

					if (alpha == BackgroundAlpha.DARKEST) {
						alpha_value = 1;
					} else if (alpha == BackgroundAlpha.LIGHTEST) {
						alpha_value = bus.get_background_alpha ();
					}
				} else {
					alpha_value = 1;
				}

				alpha_updated (alpha_value, animation_duration);
			} catch (Error e) {
				warning ("Cannot get alpha: %s", e.message);
			}
		}

		public static BackgroundManager get_default () {
			if (instance == null)
				instance = new BackgroundManager ();

			return instance;
		}
	}
}

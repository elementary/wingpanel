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
		public signal void wallpaper_changed ();

		public abstract BackgroundAlpha get_alpha (int screen) throws IOError;
		public abstract async double get_background_alpha (int screen, int panel_height) throws IOError;

		public abstract void remeber_focused_window () throws IOError;
		public abstract void restore_focused_window () throws IOError;
	}

	public class BackgroundManager : Object {
		private const string DBUS_NAME = "org.pantheon.gala.WingpanelInterface";
		private const string DBUS_PATH = "/org/pantheon/gala/WingpanelInterface";

		private const int WALLPAPER_TRANSITION_DURATION = 150;

		private static BackgroundManager? instance = null;

		private InterfaceBus bus;

		private int screen = 0;
		private int panel_height = 0;

		private double suggested_alpha = 0;

		public signal void alpha_updated (double alpha, uint animation_duration);

		public BackgroundManager () {
			if (!connect_dbus ())
				return;

			bus.alpha_changed.connect (update_panel_alpha);
			bus.wallpaper_changed.connect (() => update_suggested_alpha (WALLPAPER_TRANSITION_DURATION));

			PanelSettings.get_default ().notify["use-transparency"].connect (() => update_panel_alpha ());
			InterfaceSettings.get_default ().notify["gtk-theme"].connect (() => update_panel_alpha ());

			update_panel_alpha ();
		}

		public void init (int screen) {
			this.screen = screen;
		}

		public void remember_window () {
			try {
				bus.remeber_focused_window ();
			} catch (Error e) {
				warning ("Remembering focused window failed: %s", e.message);
			}
		}

		public void restore_window () {
			try {
				bus.restore_focused_window ();
			} catch (Error e) {
				warning ("Restoring last focused window failed: %s", e.message);
			}
		}

		public void update_panel_height (int panel_height) {
			if (this.panel_height != panel_height) {
				this.panel_height = panel_height;
				update_suggested_alpha ();
			}
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

		private bool check_use_transparency () {
			return PanelSettings.get_default ().use_transparency &&
					InterfaceSettings.get_default ().gtk_theme != "HighContrast";
		}

		private void update_suggested_alpha (uint animation_duration = 0) {
			bus.get_background_alpha.begin (screen, panel_height, (obj, res) => {
				try {
					suggested_alpha = bus.get_background_alpha.end (res);

					update_panel_alpha (animation_duration);
				} catch (Error e) {
					warning ("Updating suggested alpha failed: %s", e.message);
				}
			});
		}

		public void update_panel_alpha (uint animation_duration = 0) {
			try {
				if (check_use_transparency ()) {
					var alpha = bus.get_alpha (screen);

					if (alpha == BackgroundAlpha.DARKEST) {
						alpha_updated (1, animation_duration);
					} else if (alpha == BackgroundAlpha.LIGHTEST) {
						alpha_updated (suggested_alpha, animation_duration);
					}
				} else {
					alpha_updated (1, animation_duration);
				}
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

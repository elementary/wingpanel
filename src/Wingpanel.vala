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

namespace Wingpanel {
	public static int main (string[] args) {
		Gtk.init (ref args);

		var app = WingpanelApp.instance;

		return app.run (args);
	}

	public class WingpanelApp : Granite.Application {
		private Gtk.Window panel_window;

		construct {
			application_id = "org.elementary.wingpanel";
			program_name = _("System Panel");
			app_years = "2015";
			exec_name = "wingpanel";
			app_launcher = exec_name + ".desktop";

			build_version = "2.0";
			app_icon = "wingpanel";
			main_url = "https://launchpad.net/wingpanel";
			bug_url = "https://bugs.launchpad.net/wingpanel";
			help_url = "https://answers.launchpad.net/wingpanel";
			translate_url = "https://translations.launchpad.net/wingpanel";
			about_authors = {"Wingpanel Developers", null};

			about_license_type = Gtk.License.GPL_3_0;
		}

		public static WingpanelApp _instance = null;

		public static WingpanelApp instance {
			get {
				if (_instance == null) {
					_instance = new WingpanelApp ();
				}

				return _instance;
			}
		}

		public WingpanelApp () {
			// TODO: Setup translations and stuff like that
		}

		protected override void startup () {
		    base.startup ();

		    panel_window = new PanelWindow (this);
		    panel_window.show_all ();
		}

		protected override void activate () {
		    panel_window.present ();
		}
	}
}

#if TRANSLATION
_("A super sexy space-saving top panel");
#endif

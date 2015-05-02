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

public class Sample.Indicator : Wingpanel.Indicator {
	private Wingpanel.Widgets.DynamicIcon dynamic_icon;

	private Gtk.Grid main_grid;

	private Wingpanel.Widgets.IndicatorButton start_button;
	private Wingpanel.Widgets.IndicatorButton stop_button;

	private Wingpanel.Widgets.IndicatorSwitch test_switch;

	private Wingpanel.Widgets.IndicatorButton next_icon_button;

	private int current_icon = 0;
	private string[] icon_names = {"system-devices-panel", "audio-volume-medium-panel", "audio-volume-muted-panel", "gsm-3g-full", "gpm-keyboard-000"};

	public Indicator () {
		Object (code_name: "sample-indicator",
				display_name: _("Sample Indicator"),
				description:_("Does nothing, but it is cool!"));

		// Indicator should be visible at startup
		this.visible = true;
	}

	public override Gtk.Widget get_display_widget () {
		if (dynamic_icon == null) {
			dynamic_icon = new Wingpanel.Widgets.DynamicIcon (icon_names[current_icon]);
		}

		return dynamic_icon;
	}

	public override Gtk.Widget get_widget () {
		if (main_grid == null) {
			main_grid = new Gtk.Grid ();

			start_button = new Wingpanel.Widgets.IndicatorButton ("Im doing something...");
			start_button.clicked.connect (() => {
				dynamic_icon.start_loading ();
			});

			main_grid.attach (start_button, 0, 0, 1, 1);

			stop_button = new Wingpanel.Widgets.IndicatorButton ("Stop");
			stop_button.clicked.connect (() => {
				dynamic_icon.stop_loading ();
			});

			main_grid.attach (stop_button, 0, 1, 1, 1);

			main_grid.attach (new Wingpanel.Widgets.IndicatorSeparator (), 0, 2, 1, 1);

			test_switch = new Wingpanel.Widgets.IndicatorSwitch ("Visible", true);

			test_switch.get_switch ().notify["active"].connect (() => {
				if (!test_switch.get_switch ().active) {
					visible = false;

					Timeout.add (2000, () => {
						test_switch.get_switch ().set_active (true);
						visible = true;
						return false;
					});
				}
			});

			main_grid.attach (test_switch, 0, 3, 1, 1);

			main_grid.attach (new Wingpanel.Widgets.IndicatorSeparator (), 0, 4, 1, 1);

			next_icon_button = new Wingpanel.Widgets.IndicatorButton ("Next Icon");
			next_icon_button.clicked.connect (() => {
				current_icon++;

				if (current_icon >= icon_names.length)
					current_icon = 0;

				dynamic_icon.set_icon_name (icon_names[current_icon]);
			});

			main_grid.attach (next_icon_button, 0, 5, 1, 1);
		}

		return main_grid;
	}

	public override void opened () {
		// Use this method to get some extra information while displaying the indicator
		print ("opened\n");
	}

	public override void closed () {
		// Your stuff isn't shown anymore, now you can free some RAM, stop timers or anything else...
		print ("closed\n");
	}
}

public Wingpanel.Indicator get_indicator (Module module) {
	debug ("Activating Sample Indicator");
	var indicator = new Sample.Indicator ();
	return indicator;
}

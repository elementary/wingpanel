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
	private Gtk.Image icon;

	private Gtk.Grid main_grid;

	public Indicator () {
		Object (code_name: "sample-indicator",
				display_name: _("Sample Indicator"),
				description:_("Does nothing, but it is cool!"));
	}

	public override Gtk.Widget get_display_widget () {
		if (icon == null) {
			icon = new Gtk.Image.from_icon_name ("system-devices-panel", Gtk.IconSize.LARGE_TOOLBAR);
		}

		return icon;
	}

	public override Gtk.Widget get_widget () {
		if (main_grid == null) {
			main_grid = new Gtk.Grid ();

			var hello_label = new Gtk.Label ("Hello World!");

			main_grid.attach (hello_label, 0, 0, 1, 1);
		}

		main_grid.show_all ();

		// I do have something to display!
		this.visible = true;

// Zum Testen der Animation
Timeout.add (3000, () => {
	this.visible = !this.visible;
	return true;
});

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

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

public class Wingpanel.Widgets.Panel : Gtk.Box {
	public Panel () {
		this.hexpand = true;
		this.margin_top = 3;
		this.margin_bottom = 3;
		this.get_style_context ().add_class ("panel");

		load_indicators ();
	}

	private void load_indicators () {
		foreach (var indicator in IndicatorManager.get_default ().get_indicators ()) {
			show_indicator (indicator);
		}
	}

	private void show_indicator (Indicator indicator) {
		var indicator_entry = new IndicatorEntry (indicator);

		switch (indicator.code_name) {
			case Indicator.APP_LAUNCHER:
				indicator_entry.transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT;

				this.pack_start (indicator_entry, false, false);

				break;
			case Indicator.DATETIME:
				indicator_entry.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;

				this.set_center_widget (indicator_entry);

				break;
			default:
				indicator_entry.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;

				this.pack_end (indicator_entry, false, false);

				break;
		}
	}
}

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

public class Wingpanel.Widgets.DynamicIcon : Gtk.Stack {
	private Gtk.Image display_icon;
	private Gtk.Spinner display_spinner;

	public DynamicIcon (string icon_name) {
		display_icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.LARGE_TOOLBAR);
		display_icon.icon_size = 24;
		display_icon.pixel_size = 24;

		display_spinner = new Gtk.Spinner ();

		this.add (display_icon);
		this.add (display_spinner);
	}

	public void set_icon_name (string icon_name) {
		display_icon.set_from_icon_name (icon_name, Gtk.IconSize.LARGE_TOOLBAR);
	}

	public string get_icon_name () {
		string icon_name;
		Gtk.IconSize icon_size;

		display_icon.get_icon_name (out icon_name, out icon_size);

		return icon_name;
	}

	public Gtk.Image get_icon () {
		return display_icon;
	}

	public Gtk.Spinner get_spinner () {
		return display_spinner;
	}

	public void start_loading () {
		display_spinner.start ();

		this.set_visible_child (display_spinner);
	}

	public void stop_loading () {
		display_spinner.stop ();

		this.set_visible_child (display_icon);
	}
}

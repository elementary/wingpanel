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

public class Wingpanel.Widgets.DynamicIcon: Gtk.Stack {
	private Gtk.Image icon;
	private Gtk.Spinner spinner;

	public DynamicIcon (string icon_name) {
		icon = new Gtk.Image.from_icon_name (icon_name, Gtk.IconSize.LARGE_TOOLBAR);
		icon.icon_size = 24;
		icon.pixel_size = 24;

		spinner = new Gtk.Spinner ();

		this.add (icon);
		this.add (spinner);
	}

	public void set_icon_name (string icon_name) {
		icon.icon_name = icon_name;
	}

	public string get_icon_name () {
		return icon.icon_name;
	}

	public Gtk.Image get_icon () {
		return icon;
	}

	public Gtk.Spinner get_spinner () {
		return spinner;
	}

	public void start_loading () {
		spinner.start ();
		this.set_visible_child (spinner);
	}

	public void stop_loading () {
		spinner.stop ();
		this.set_visible_child (icon);
	}
}

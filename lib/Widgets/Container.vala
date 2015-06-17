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

public class Wingpanel.Widgets.Container : Gtk.Button {
	private Gtk.Grid content_widget;

	public Container () {
		content_widget = new Gtk.Grid ();

		this.add (content_widget);

		set_style_classes ();
	}

	public Gtk.Grid get_content_widget () {
		return content_widget;
	}

	private void set_style_classes () {
		var style_context = this.get_style_context ();
		style_context.add_class (Gtk.STYLE_CLASS_MENUITEM);
		style_context.remove_class (Gtk.STYLE_CLASS_BUTTON);
		style_context.remove_class ("text-button");
	}
}

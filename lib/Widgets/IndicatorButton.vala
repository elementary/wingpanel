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

public class Wingpanel.Widgets.IndicatorButton : Gtk.Button {
	private Gtk.Label button_label;

	private new Gtk.Image image;

	public IndicatorButton (string caption) {
		// FIXME: Use the "indicator-button" class in the stylesheet to configure how the button is rendered.
		this.label = Markup.escape_text (caption);
		this.hexpand = true;

		button_label = this.get_child () as Gtk.Label;
		button_label.use_markup = true;
		button_label.halign = Gtk.Align.START;
		button_label.margin_start = 6;
		button_label.margin_end = 10;

		var style_context = this.get_style_context ();
		style_context.add_class (Gtk.STYLE_CLASS_MENUITEM);
		style_context.remove_class (Gtk.STYLE_CLASS_BUTTON);
		style_context.remove_class ("text-button");
	}

	public IndicatorButton.with_image (string caption, Gdk.Pixbuf pixbuf) {
		this.hexpand = true;

		var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

		button_label = new Gtk.Label (Markup.escape_text (caption));

		button_label.use_markup = true;
		button_label.margin_start = 3;
		button_label.margin_end = 10;

		image = new Gtk.Image ();
		image.pixbuf = pixbuf;
		image.margin_start = 6;

		box.add (image);
		box.add (button_label);

		this.add (box);

		var style_context = this.get_style_context ();
		style_context.add_class (Gtk.STYLE_CLASS_MENUITEM);
		style_context.remove_class (Gtk.STYLE_CLASS_BUTTON);
		style_context.remove_class ("text-button");
	}

	public void set_caption (string caption) {
		button_label.set_label (Markup.escape_text (caption));
	}

	public string get_caption () {
		return button_label.get_label ();
	}
}

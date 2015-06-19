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

public class Wingpanel.Widgets.Button : Container {
	private Gtk.Label button_label;

	private Gtk.Image button_image;

	public Button (string caption, Gdk.Pixbuf? pixbuf = null) {
		var content_widget = this.get_content_widget ();

		button_image = create_image_for_pixbuf (pixbuf);
		button_label = create_label_for_caption (caption);

		content_widget.attach (button_image, 0, 0, 1, 1);
		content_widget.attach (button_label, 1, 0, 1, 1);

		connect_signals ();
	}

	public Button.with_mnemonic (string caption, Gdk.Pixbuf? pixbuf = null) {
		var content_widget = this.get_content_widget ();

		button_image = create_image_for_pixbuf (pixbuf);
		button_label = create_label_for_caption (caption, true);

		content_widget.attach (button_image, 0, 0, 1, 1);
		content_widget.attach (button_label, 1, 0, 1, 1);

		connect_signals ();
	}

	public void set_caption (string caption) {
		button_label.set_label (Markup.escape_text (caption));
	}

	public string get_caption () {
		return button_label.get_label ();
	}

	public void set_pixbuf (Gdk.Pixbuf? pixbuf) {
		button_image.set_from_pixbuf (pixbuf);
	}

	public Gdk.Pixbuf? get_pixbuf () {
		return button_image.get_pixbuf ();
	}

	public new Gtk.Label get_label () {
		return button_label;
	}

	private Gtk.Label create_label_for_caption (string caption, bool use_mnemonic = false) {
		Gtk.Label label_widget;

		if (use_mnemonic) {
			label_widget = new Gtk.Label.with_mnemonic (Markup.escape_text (caption));
			label_widget.set_mnemonic_widget (this);
		} else {
			label_widget = new Gtk.Label (Markup.escape_text (caption));
		}

		label_widget.use_markup = true;
		label_widget.halign = Gtk.Align.START;
		label_widget.margin_start = 6;
		label_widget.margin_end = 10;

		return label_widget;
	}

	private Gtk.Image create_image_for_pixbuf (Gdk.Pixbuf? pixbuf) {
		var image = new Gtk.Image ();
		image.pixbuf = pixbuf;
		image.margin_start = 6;
		image.no_show_all = true;
		image.visible = pixbuf != null;

		return image;
	}

	private void connect_signals () {
		button_image.notify["pixbuf"].connect (() => {
			button_image.visible = button_image.get_pixbuf () != null;
		});
	}
}

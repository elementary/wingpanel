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

public class Wingpanel.Widgets.OverlayIcon : Gtk.Overlay {
	private Gtk.Image main_image;

	private Gtk.Image overlay_image;

	public OverlayIcon (Gdk.Pixbuf main_pixbuf, Gdk.Pixbuf overlay_pixbuf) {
		main_image = new Gtk.Image.from_pixbuf (main_pixbuf);
		overlay_image = new Gtk.Image.from_pixbuf (overlay_pixbuf);

		this.add_overlay (main_image);
		this.add_overlay (overlay_image);
	}

	public void set_main_pixbuf (Gdk.Pixbuf? pixbuf) {
		main_image.set_from_pixbuf (pixbuf);
	}

	public Gdk.Pixbuf? get_main_pixbuf () {
		return main_image.get_pixbuf ();
	}

	public void set_overlay_pixbuf (Gdk.Pixbuf? pixbuf) {
		overlay_image.set_from_pixbuf (pixbuf);
	}

	public Gdk.Pixbuf? get_overlay_pixbuf () {
		return overlay_image.get_pixbuf ();
	}

	public Gtk.Image get_main_image () {
		return main_image;
	}

	public Gtk.Image get_overlay_image () {
		return overlay_image;
	}
}

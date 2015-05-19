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

public class Wingpanel.Utils {

	/**
	 * Utility function for compositing icons.
	 * Make sure that both {@link Gdk.Pixbuf} are the same size.
	 * @param two {@link Gdk.Pixbuf}
	 * @return composited {@link Gdk.Pixbuf}
	 */
	public static Gdk.Pixbuf composite (Gdk.Pixbuf pix1, Gdk.Pixbuf pix2) {
		var w = pix1.get_width();
		var h = pix1.get_height();
		var dest = pix2.copy ();

		pix1.composite (dest, 0, 0, w, h, 0, 0, 1.0, 1.0, Gdk.InterpType.BILINEAR, 255);

		return dest;
	}
}
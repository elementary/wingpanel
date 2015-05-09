public class KeyboardInput : Gtk.Image {
	private string icon_svg_data = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><svg version=\"1.1\" width=\"24\" height=\"24\"><defs><mask id=\"m\"><rect x=\"0\" y=\"0\" width=\"24\" height=\"24\" style=\"fill:white\"/><text x=\"%s\" y=\"15.5\" style=\"font-family:Open Sans;font-weight:500;font-size:9;fill:black\">%s</text></mask></defs><rect x=\"4\" y=\"4\" width=\"16\" height=\"16\" rx=\"2\" mask=\"url(#m)\" style=\"fill:#fff\"/></svg>";
	// private string icon_svg_data2 = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><svg version=\"1.1\" width=\"24\" height=\"24\"><defs><mask id=\"m\"><rect x=\"0\" y=\"0\" width=\"24\" height=\"24\" style=\"fill:white\"/><text x=\"%s\" y=\"15.5\" style=\"font-family:Open Sans;font-weight:500;font-size:9;fill:black\">%s</text><text x=\"%s\" y=\"18.5\" style=\"font-family:Open Sans;font-weight:500;font-size:8;fill:black\">%d</text></mask></defs><rect x=\"4\" y=\"4\" width=\"16\" height=\"16\" rx=\"2\" mask=\"url(#m)\" style=\"fill:#fff\"/></svg>";
	private Cairo.Context context;

	public KeyboardInput() {
		Cairo.ImageSurface surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, 1, 1);
		context = new Cairo.Context (surface);
		context.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
	}

	// calculate x: middle line (24/2) - text_extent.width / 2
	public void set_lang (string code) {
		try {
			context.set_font_size (9);
			Cairo.TextExtents extents;
			context.text_extents (code, out extents);
			var replace_svg = icon_svg_data.printf ((12 - extents.width/2).to_string (),code);
			var input = new GLib.MemoryInputStream.from_data (replace_svg.data, GLib.g_free);
			this.pixbuf = new Gdk.Pixbuf.from_stream (input);
		} catch (Error e) {}
	}

	// TODO calculate the right x position in combination with a subscript
	public void set_lang_with_subscript (string code, int subscript) {
		// try {
		// 	context.set_font_size (9);
		// 	Cairo.TextExtents extents;
		// 	context.text_extents (code, out extents);
		// 	context.set_font_size (8);
			// Cairo.TextExtents extents2;
			// context.text_extents ("%d".printf (subscript), out extents2);
			// print ("%s %f  %d %f\n", code, extents.width, subscript, extents2.width);
			// var replace_svg = icon_svg_data2.printf ((12.5 - extents.width).to_string (),code,
			// 					(22.5 - extents2.width).to_string (), subscript);
			// print (replace_svg);
			// var input = new GLib.MemoryInputStream.from_data (replace_svg.data, GLib.g_free);
			// this.pixbuf = new Gdk.Pixbuf.from_stream (input);
		// } catch (Error e) {}

	}
}
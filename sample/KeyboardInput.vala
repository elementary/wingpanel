public class KeyboardInput : Gtk.Image {
	private string icon_svg_data;
	private Cairo.Context context;

	public KeyboardInput() {
		try {
			var file = File.new_for_path ("/usr/share/icons/elementary/panel/24/indicator-keyboard-Ak.svg");
			var dis = new DataInputStream (file.read ());
			icon_svg_data = dis.read_line (null).replace ("6.5", "%s").replace ("Ak","%s");
			Cairo.ImageSurface surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, 1, 1);
			context = new Cairo.Context (surface);
			context.select_font_face ("Open Sans", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
		} catch (Error e) {
			critical ("unable to load svg: %s", e.message);
		}
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
		} catch (Error e) {
			warning ("unable to set pixbuf: %s", e.message);
		}
	}
}
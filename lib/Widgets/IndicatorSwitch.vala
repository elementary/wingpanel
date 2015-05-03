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

public class Wingpanel.Widgets.IndicatorSwitch : Gtk.Grid {
	private Gtk.Label label_widget;
	private Gtk.Switch switch_widget;

	public IndicatorSwitch (string caption, bool active = false) {
		this.hexpand = true;
		this.margin_top = 6;
		this.margin_bottom = 3;
		this.margin_start = 6;
		this.margin_end = 6;

		// FIXME: Replace this with some css-rules
		label_widget = new Gtk.Label ("<span weight='normal'>%s</span>".
				printf (Markup.escape_text (caption)));
		label_widget.use_markup = true;
		label_widget.hexpand = true;
		label_widget.halign = Gtk.Align.START;
		label_widget.margin_start = 6;

		this.attach (label_widget, 0, 0, 1, 1);

		switch_widget = new Gtk.Switch ();
		switch_widget.active = active;
		switch_widget.halign = Gtk.Align.END;
		switch_widget.margin_start = 12;

		this.attach (switch_widget, 1, 0, 1, 1);

		this.get_style_context ().add_class ("indicator-switch");
	}

	public void set_caption (string caption) {
		label_widget.set_label ("<span weight='normal'>%s</span>".
				printf (Markup.escape_text (caption)));
	}

	// TODO: Add get_caption () method when that markup-stuff is away

	public void set_active (bool active) {
		switch_widget.set_active (active);
	}

	public bool get_active () {
		return switch_widget.get_active ();
	}

	public Gtk.Label get_label () {
		return label_widget;
	}

	public Gtk.Switch get_switch () {
		return switch_widget;
	}
}

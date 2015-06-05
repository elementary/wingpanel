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

public class Wingpanel.Widgets.IndicatorSwitch : Gtk.Button {
	private Gtk.Label label_widget;
	private Gtk.Switch switch_widget;

	public IndicatorSwitch (string caption, bool active = false) {
		this.hexpand = true;

		var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

		label_widget = new Gtk.Label (Markup.escape_text (caption));

		label_widget.use_markup = true;
		label_widget.margin_start = 6;
		label_widget.margin_end = 10;

		switch_widget = new Gtk.Switch ();
		switch_widget.active = active;
		switch_widget.halign = Gtk.Align.END;

		box.add (label_widget);
		box.pack_end (switch_widget);

		this.add (box);

		this.button_press_event.connect ((e) => {
			set_active (!get_active ());

			return false;
		});

		var style_context = this.get_style_context ();
		style_context.add_class (Gtk.STYLE_CLASS_MENUITEM);
		style_context.remove_class (Gtk.STYLE_CLASS_BUTTON);
		style_context.remove_class ("text-button");
	}


	public IndicatorSwitch.with_mnemonic (string caption, bool active = false) {
		this.hexpand = true;

		var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

		label_widget = new Gtk.Label.with_mnemonic (caption);
		label_widget.set_mnemonic_widget (this);

		label_widget.use_markup = true;
		label_widget.margin_start = 6;
		label_widget.margin_end = 10;

		switch_widget = new Gtk.Switch ();
		switch_widget.active = active;
		switch_widget.halign = Gtk.Align.END;

		box.add (label_widget);
		box.pack_end (switch_widget);

		this.add (box);

		this.button_press_event.connect ((e) => {
			set_active (!get_active ());

			return false;
		});

		var style_context = this.get_style_context ();
		style_context.add_class (Gtk.STYLE_CLASS_MENUITEM);
		style_context.remove_class (Gtk.STYLE_CLASS_BUTTON);
		style_context.remove_class ("text-button");
	}

	public void set_caption (string caption) {
		label_widget.set_label (caption);
	}

	public string get_caption () {
		return label_widget.get_label ();
	}

	public void set_active (bool active) {
		switch_widget.set_active (active);
	}

	public bool get_active () {
		return switch_widget.get_active ();
	}

	public new Gtk.Label get_label () {
		return label_widget;
	}

	public Gtk.Switch get_switch () {
		return switch_widget;
	}
}

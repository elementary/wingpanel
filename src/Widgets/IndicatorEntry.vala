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

public class Wingpanel.Widgets.IndicatorEntry : Gtk.MenuItem {
	private Gtk.Widget display_widget;
	private Gtk.Widget indicator_widget;

	private Gtk.Revealer revealer;

	private IndicatorPopover popover;
	public Indicator base_indicator;

	public IndicatorEntry (Indicator base_indicator, Services.PopoverManager popover_manager) {
		this.base_indicator = base_indicator;
		this.halign = Gtk.Align.START;
		this.get_style_context ().add_class ("composited-indicator");

		display_widget = base_indicator.get_display_widget ();
		indicator_widget = base_indicator.get_widget ();

		revealer = new Gtk.Revealer ();

		set_reveal (base_indicator.visible);

		base_indicator.notify["visible"].connect (() => set_reveal (base_indicator.visible));

		display_widget.margin_start = 6;
		display_widget.margin_end = 6;

		revealer.add (display_widget);

		popover = new IndicatorPopover (indicator_widget);
		popover.relative_to = this;

		popover_manager.register_popover (this, popover);

		this.button_press_event.connect ((e) => {
			if (e.button != 1) {
				return Gdk.EVENT_PROPAGATE;
			}

			if (popover.get_visible ())
				popover.hide ();
			else
				popover.show_all ();

			return Gdk.EVENT_STOP;
		});

		this.add (revealer);
	}

	public void set_transition_type (Gtk.RevealerTransitionType transition_type) {
		revealer.set_transition_type (transition_type);
	}

	private void set_reveal (bool reveal) {
		if (!reveal && popover.get_visible ())
			popover.hide ();

		revealer.set_reveal_child (reveal);
	}
}

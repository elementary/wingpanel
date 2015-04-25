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

public class Wingpanel.Widgets.IndicatorEntry : Gtk.Revealer {
	private Gtk.Widget display_widget;
	private Gtk.Widget indicator_widget;

	private IndicatorPopover popover;

	public IndicatorEntry (Indicator base_indicator) {
		this.halign = Gtk.Align.START;
		this.get_style_context ().add_class ("composited-indicator");

		display_widget = base_indicator.get_display_widget ();
		indicator_widget = base_indicator.get_widget ();

		set_reveal (base_indicator.visible);

		base_indicator.notify.connect ((param) => {
			switch (param.get_name ()) {
				case "visible":
					set_reveal (base_indicator.visible);

					break;
			}
		});

		display_widget.margin_start = 6;
		display_widget.margin_end = 6;

		this.add (display_widget);

		popover = new IndicatorPopover (indicator_widget);

		this.set_events (Gdk.EventMask.BUTTON_PRESS_MASK);
		this.button_press_event.connect ((e) => {
			if (e.button != 1) {
				return Gdk.EVENT_PROPAGATE;
			}

			if (popover.get_visible ()) {
				// Hide the popover before telling the indicator about it to prevent indication errors
				popover.hide ();
				base_indicator.closed ();
			} else {
				// Show the popover when it's ready
				base_indicator.opened ();
				popover.show ();
			}

			return Gdk.EVENT_STOP;
		});
	}

	private void set_reveal (bool reveal) {
		this.set_reveal_child (reveal);
	}
}

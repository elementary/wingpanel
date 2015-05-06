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

public class Wingpanel.Widgets.Panel : Gtk.Box {
	private Services.PopoverManager popover_manager;

	private IndicatorMenuBar right_menubar;
	private MenuBar left_menubar;
	private MenuBar center_menubar;

	private int background_alpha = 0; // 0 - 100

	public Panel (Services.PopoverManager popover_manager) {
		Object (orientation: Gtk.Orientation.HORIZONTAL);

		this.popover_manager = popover_manager;

		this.hexpand = true;
		this.vexpand = false;
		this.valign = Gtk.Align.START;
		this.get_style_context ().add_class (StyleClass.PANEL);

		left_menubar = new MenuBar ();
		left_menubar.halign = Gtk.Align.START;

		this.pack_start (left_menubar);

		center_menubar = new MenuBar ();

		this.set_center_widget (center_menubar);

		right_menubar = new IndicatorMenuBar ();
		right_menubar.halign = Gtk.Align.END;

		this.pack_end (right_menubar);

		load_indicators ();

		IndicatorManager.get_default ().indicator_added.connect ((indicator) => {
			show_indicator (indicator);
		});

		IndicatorManager.get_default ().indicator_removed.connect ((indicator) => {
			remove_indicator (indicator);
		});
	}

	private void load_indicators () {
		IndicatorManager.get_default ().get_indicators ().@foreach ((entry) => {
			show_indicator (entry.value);

			return true;
		});
	}

	private void show_indicator (Indicator indicator) {
		var indicator_entry = new IndicatorEntry (indicator, popover_manager);

		switch (indicator.code_name) {
			case Indicator.APP_LAUNCHER:
				indicator_entry.set_transition_type (Gtk.RevealerTransitionType.SLIDE_RIGHT);

				left_menubar.add (indicator_entry);

				break;
			case Indicator.DATETIME:
				indicator_entry.set_transition_type (Gtk.RevealerTransitionType.SLIDE_DOWN);

				center_menubar.add (indicator_entry);

				break;
			default:
				indicator_entry.set_transition_type (Gtk.RevealerTransitionType.SLIDE_LEFT);

				right_menubar.insert_sorted (indicator_entry);

				break;
		}

		indicator_entry.show_all ();
	}

	private void remove_indicator (Indicator indicator) {
		remove_indicator_from_container (left_menubar, indicator);
		remove_indicator_from_container (center_menubar, indicator);
		remove_indicator_from_container (right_menubar, indicator);
	}

	private void remove_indicator_from_container (Gtk.Container container, Indicator indicator) {
		foreach (var child in container.get_children ()) {
			if (child is IndicatorEntry){
				if ((child as IndicatorEntry).base_indicator == indicator) {
					container.remove (child);

					return;
				}
			}
		}
	}

	private void animate_color (bool make_dark) {
		if ((make_dark && background_alpha >= 100) || (!make_dark && background_alpha <= 0))
			return;

		Timeout.add (300 / 100, () => {
			double new_alpha;

			if (make_dark)
				new_alpha = (double)(++background_alpha) / 100;
			else
				new_alpha = (double)(--background_alpha) / 100;

			this.override_background_color (Gtk.StateFlags.NORMAL, {0, 0, 0, new_alpha});

			return (background_alpha < 100 && make_dark) || (background_alpha > 0 && !make_dark);
		});
	}
}

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
	private static const double ALPHA_ANIMATION_STEP = 0.05;

	public Services.PopoverManager popover_manager { get; construct; }

	private IndicatorMenuBar right_menubar;
	private MenuBar left_menubar;
	private MenuBar center_menubar;

	private double current_alpha;
	private double alpha_animation_target = 0;

	public Panel (Services.PopoverManager popover_manager) {
		Object (popover_manager: popover_manager, orientation: Gtk.Orientation.HORIZONTAL);

		this.set_size_request (-1, 24);

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

		unowned IndicatorManager indicator_manager = IndicatorManager.get_default ();
		indicator_manager.get_indicators ().@foreach ((indicator) => {
			add_indicator (indicator);

			return true;
		});
		indicator_manager.indicator_added.connect (add_indicator);
		indicator_manager.indicator_removed.connect (remove_indicator);

		Services.BackgroundManager.get_default ().alpha_updated.connect (animate_background);
	}

	private void add_indicator (Indicator indicator) {
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
		foreach (unowned Gtk.Widget child in container.get_children ()) {
			unowned IndicatorEntry? entry = (child as IndicatorEntry);
			if (entry != null && entry.base_indicator == indicator) {
					container.remove (child);

					return;
			}
		}
	}

	private void animate_background (double alpha, uint animation_duration) {
		if (animation_duration == 0) {
			current_alpha = alpha;
			this.override_background_color (Gtk.StateFlags.NORMAL, {0, 0, 0, current_alpha});

			return;
		}

		if (alpha_animation_target == alpha)
			return;

		alpha_animation_target = alpha;

		assert (ALPHA_ANIMATION_STEP > 0);

		if (current_alpha - alpha == 0)
			return;

		int step_count = ((int)((current_alpha - alpha) / ALPHA_ANIMATION_STEP)).abs ();

		if (step_count <= 0)
			return;

		Timeout.add (animation_duration / step_count, () => {
			// Has another animation started?
			if (alpha_animation_target != alpha)
				return false;

			var cont = false;

			if (current_alpha < alpha_animation_target) {
				current_alpha += ALPHA_ANIMATION_STEP;

				cont = current_alpha < alpha_animation_target;
			} else {
				current_alpha -= ALPHA_ANIMATION_STEP;

				cont = current_alpha > alpha_animation_target;
			}

			this.override_background_color (Gtk.StateFlags.NORMAL, {0, 0, 0, current_alpha});

			return cont;
		});
	}
}

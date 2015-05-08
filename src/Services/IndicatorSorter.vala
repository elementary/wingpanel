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

/**
 * Indicator sorter class.
 *
 * This class is composed of static methods because compare_func() needs
 * to be static in order to work properly, since instance methods cannot
 * be passed as CompareFuncs.
 */
public class Wingpanel.Services.IndicatorSorter : Object {
	public int compare_func (Wingpanel.Widgets.IndicatorEntry? a, Wingpanel.Widgets.IndicatorEntry? b) {
		if (a == null)
			return (b == null) ? 0 : -1;

		if (b == null)
			return 1;

		int order = get_order (a) - get_order (b);

		if (order == 0)
			order = compare_entries_by_name (a, b);

		return order.clamp (-1, 1);
	}

	// Whenever two different entries  are not part of the default order list,
	// we sort them using their individual name hints.
	private static int compare_entries_by_name (Wingpanel.Widgets.IndicatorEntry a, Wingpanel.Widgets.IndicatorEntry b) {
		return strcmp (a.base_indicator.code_name.down (), b.base_indicator.code_name.down ());
	}

	private static int get_order (Wingpanel.Widgets.IndicatorEntry node) {
		int best_match = 0;

		// ayatana application indicators on the left of the native indicators
		if (node.base_indicator.code_name.has_prefix ("ayatana-"))
			return best_match;

		var order = Wingpanel.Services.Settings.get_default ().order;

		for (int i = 0; i < order.length; i++) {
			var order_name = order[i];

			if (order_name == node.base_indicator.code_name) {
				best_match = i;

				break;
			}
		}

		return best_match;
	}
}

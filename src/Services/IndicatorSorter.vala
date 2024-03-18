/*
 * Copyright 2011-2020 elementary, Inc. (https://elementary.io)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */

/**
 * Indicator sorter class.
 *
 * This class is composed of static methods because compare_func() needs
 * to be static in order to work properly, since instance methods cannot
 * be passed as CompareFuncs.
 */
public class Wingpanel.Services.IndicatorSorter : Object {
    private const string UNKNOWN_INDICATOR = "xxx-unknown";
    private const string AYATANA_INDICATOR = "xxx-ayatana";

    /* The order in which the indicators are shown from left to right. */
    private static Gee.HashMap<string, int> indicator_order = new Gee.HashMap<string,int> ();
    static construct {
        indicator_order[AYATANA_INDICATOR] = 0;
        indicator_order[UNKNOWN_INDICATOR] = 1;
        indicator_order[Indicator.ACCESSIBILITY] = 2;
        indicator_order[Indicator.NIGHT_LIGHT] = 3;
        indicator_order[Indicator.PRIVACY] = 4;
        indicator_order[Indicator.KEYBOARD] = 5;
        indicator_order[Indicator.SOUND] = 6;
        indicator_order[Indicator.NETWORK] = 7;
        indicator_order[Indicator.BLUETOOTH] = 8;
        indicator_order[Indicator.PRINTER] = 9;
        indicator_order[Indicator.SYNC] = 10;
        indicator_order[Indicator.POWER] = 11;
        indicator_order[Indicator.MESSAGES] = 12;
        indicator_order[Indicator.QUICKSETTINGS] = 13;
        indicator_order[Indicator.SESSION] = 14;
    }

    public int compare_func (Wingpanel.Widgets.IndicatorEntry? a, Wingpanel.Widgets.IndicatorEntry? b) {
        if (a == null) {
            return (b == null) ? 0 : -1;
        }

        if (b == null) {
            return 1;
        }

        int order = get_order (a) - get_order (b);

        if (order == 0) {
            order = compare_entries_by_name (a, b);
        }

        return order.clamp (-1, 1);
    }

    /*
     * Whenever two different entries  are not part of the default order list,
     * we sort them using their individual name hints.
     */
    private static int compare_entries_by_name (Wingpanel.Widgets.IndicatorEntry a, Wingpanel.Widgets.IndicatorEntry b) {
        return strcmp (a.base_indicator.code_name.down (), b.base_indicator.code_name.down ());
    }

    private static int get_order (Wingpanel.Widgets.IndicatorEntry node) {
        /* ayatana application indicators on the left of the native indicators */
        if (node.base_indicator.code_name.has_prefix ("ayatana-")) {
            return indicator_order[AYATANA_INDICATOR];
        }

        if (indicator_order.has_key (node.base_indicator.code_name)) {
            return indicator_order[node.base_indicator.code_name];
        }

        return indicator_order[UNKNOWN_INDICATOR];
    }
}

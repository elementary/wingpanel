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

/** A scroll box that will take its child height unless it is higher than 512
 * (i.e. the value of max_height).
 * If it is actually higher than max_height, then it will stick to max_height.
 **/
public class Wingpanel.Widgets.AutomaticScrollBox : Gtk.ScrolledWindow {
    /** The maximal height of the scroll box before it starts scrolling. **/
    public int max_height { default = 512; get; set; }

    /** The adjustments are here to ensure the compatibility with Gtk.ScrolledWindow,
     * but you should probably not use them, as the height of this widget is dynamic.
     **/
    public AutomaticScrollBox (Gtk.Adjustment? hadj = null, Gtk.Adjustment? vadj = null) {
        Object (hadjustment:hadj, vadjustment:vadj);

        notify["max-height"].connect(queue_resize);
    }

    public override void get_preferred_height_for_width (int width, out int minimum_height, out int natural_height) {
        Gtk.Widget child = get_child ();
        if (child != null) {
            child.get_preferred_height_for_width(width, out minimum_height, out natural_height);

            minimum_height = int.min (max_height, minimum_height);
            natural_height = int.min (max_height, natural_height);
        } else {
            minimum_height = natural_height = 0;
        }
    }

    public override void get_preferred_height (out int minimum_height, out int natural_height) {
        Gtk.Widget child = get_child ();
        if (child != null) {
            child.get_preferred_height(out minimum_height, out natural_height);

            minimum_height = int.min (max_height, minimum_height);
            natural_height = int.min (max_height, natural_height);
        } else {
            minimum_height = natural_height = 0;
        }
    }
}

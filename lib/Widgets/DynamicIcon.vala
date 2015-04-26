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


public class Wingpanel.Widgets.DynamicIcon: Gtk.Stack {
    private Gtk.Spinner spinner;
    private Gtk.Image icon;
    
    public Wingpanel.Widgets.DynamicIcon (string icon_name_) {
        this.set_transition_type (StackTransitionType.CROSSFADE);

        spinner = new Gtk.Spinner ();
        icon = new Gtk.Image.from_icon_name (icon_name_, IconSize.MENU);

        this.add (spinner);
        this.add (icon);
        this.show_icon (); //Show icon by default?
    }
    
    public void show_spinner () {
        spinner.start ();
        set_visible_child (spinner);
    }
    
    public void show_icon () {
        spinner.stop ();
        set_visible_child (icon);
    }
}

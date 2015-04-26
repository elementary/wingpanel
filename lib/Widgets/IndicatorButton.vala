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

public class Wingpanel.Widgets.IndicatorButton : Gtk.Button {
	public Wingpanel.Widgets.IndicatorButton (string caption) {
	    this.set_label (caption);
		this.margin_start = 20;
		(this.get_child () as Gtk.Label).xalign = 0;
		
		//Add the CSS lines to egtk or to the app via ctrl + shift + d
        this.get_style_context ().add_class ("indicator-menu-item");
        this.get_style_context ().add_class ("h3");
	}		
}

/* 
CSS: 
# This is what I used on the mockup indicators I made. Feel free to change
#    -Felipe

.indicator-menu-item {
    text-shadow: 0 1px alpha (#fff, 0.4);
    icon-shadow: 0 1px alpha (#fff, 0.4);

    background-image: linear-gradient(to bottom,
                                  transparent,
                                  transparent 50%,
                                  alpha (#000, 0.00)
                                  );

    border: 0px solid alpha (#000, 0.2);
    border-radius: 0px;

    box-shadow: inset 0 0 0 0px alpha (#fff, 0.05),
                inset 0 0px 0 0 alpha (#fff, 0.45),
                inset 0 0px 0 0 alpha (#fff, 0.15),
                0 0px 0 0 alpha (#fff, 0.15);

    color: @text_color;

    transition: all 100ms ease-in;
}

.indicator-menu-item:backdrop {
    background-image: none;

    border: 0px solid alpha (#000, 0.2);
}

.indicator-menu-item:hover {
    color:@text_color;
    background-color: alpha (#000, 0.03);
    background-image: none;
    border-color: alpha (#000, 0.25);

    box-shadow: inset 0 0 0 1px alpha (#000, 0.05),
                0 1px 0 0 alpha (#fff, 0.30);
}

.indicator-menu-item:active {
    color:@text_color;
    background-color: alpha (#000, 0.08);
    background-image: none;
    border-color: alpha (#000, 0.25);

    box-shadow: inset 0 0 0 1px alpha (#000, 0.05),
                0 1px 0 0 alpha (#fff, 0.30);
}
*/

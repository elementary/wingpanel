/*
 * Copyright (c) 2011-2018 elementary, Inc. (https://elementary.io)
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
 * This small example shows how to use the wingpanel api to create a simple indicator
 * and how to make use of some useful helper widgets.
 */
public class Sample.Indicator : Wingpanel.Indicator {
    /* Our display widget, a Gtk.Overlay */
    private Gtk.Overlay display_widget;

    /* The main widget that is displayed in the popover */
    private Gtk.Box main_widget;

    public Indicator () {
        /* Some information about the indicator */
        Object (
            code_name : "sample-indicator" /* Unique name */
        );
    }

    construct {
        var main_image = new Gtk.Image () {
            icon_name = "dialog-information-symbolic",
            pixel_size = 24
        };

        var overlay_image = new Gtk.Image () {
            pixel_size = 24
        };

        /* Create a new composited icon */
        display_widget = new Gtk.Overlay () {
            child = main_image
        };
        display_widget.add_overlay (overlay_image);

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 3,
            margin_bottom = 3
        };

        var hide_button = new Gtk.Button.with_label (_("Hide me!"));
        hide_button.get_style_context ().add_class (Granite.STYLE_CLASS_FLAT);
        hide_button.get_style_context ().add_class (Granite.STYLE_CLASS_MENUITEM);

        var compositing_switch = new Granite.SwitchModelButton (_("Composited Icon"));

        main_widget = new Gtk.Box (VERTICAL, 0);
        main_widget.append (hide_button);
        main_widget.append (separator);
        main_widget.append (compositing_switch);

        /* Indicator should be visible at startup */
        this.visible = true;

        hide_button.clicked.connect (() => {
            this.visible = false;

            Timeout.add (2000, () => {
                this.visible = true;
                return false;
            });
        });

        compositing_switch.notify["active"].connect (() => {
            /* If the switch is enabled set the icon name of the icon that should be drawn on top of the other one, if not hide the top icon. */
            overlay_image.icon_name = compositing_switch.active ? "network-vpn-lock-symbolic" : "";
        });
    }

    /* This method is called to get the widget that is displayed in the panel */
    public override Gtk.Widget get_display_widget () {
        return display_widget;
    }

    /* This method is called to get the widget that is displayed in the popover */
    public override Gtk.Widget? get_widget () {
        return main_widget;
    }

    /* This method is called when the indicator popover opened */
    public override void opened () {
        /* Use this method to get some extra information while displaying the indicator */
    }

    /* This method is called when the indicator popover closed */
    public override void closed () {
        /* Your stuff isn't shown anymore, now you can free some RAM, stop timers or anything else... */
    }
}

/*
 * This method is called once after your plugin has been loaded.
 * Create and return your indicator here if it should be displayed on the current server.
 */
public Wingpanel.Indicator? get_indicator (Module module, Wingpanel.IndicatorManager.ServerType server_type) {
    /* A small message for debugging reasons */
    debug ("Activating Sample Indicator");

    /* Check which server has loaded the plugin */
    if (server_type != Wingpanel.IndicatorManager.ServerType.SESSION) {
        /* We want to display our sample indicator only in the "normal" session, not on the login screen, so stop here! */
        return null;
    }

    /* Create the indicator */
    var indicator = new Sample.Indicator ();

    /* Return the newly created indicator */
    return indicator;
}

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
    /* Our display widget, a composited icon */
    // private Wingpanel.Widgets.OverlayIcon display_widget;
    private Gtk.Grid? indicator_grid = null;

    /* The main widget that is displayed in the popover */
    private Gtk.Grid main_widget;

    public Indicator () {
        /* Some information about the indicator */
        Object (
            code_name : Wingpanel.Indicator.QUICK_LAUNCH /* Unique name */
        );
    }

    /* This method is called to get the widget that is displayed in the panel */
    public override Gtk.Widget get_display_widget () {

        // return display_widget;
        if (indicator_grid == null) {
            weak Gtk.IconTheme default_theme = Gtk.IconTheme.get_default ();
            default_theme.add_resource_path ("/io/elementary/wingpanel");

            var workspaces_label = new Gtk.Label (_("Spaces")) {
                vexpand = true
            };

            var workspaces_icon = new Gtk.Image.from_icon_name ("workspaces-symbolic", Gtk.IconSize.MENU);

            string[] workspaces_accels = {};
            workspaces_accels += "<Super>s";
            workspaces_accels += "<Super>Down";

            var workspaces_grid = new Gtk.Grid () {
                tooltip_markup = Granite.markup_accel_tooltip (workspaces_accels, _("Multitasking View"))
            };
            workspaces_grid.add (workspaces_icon);
            // workspaces_grid.add (workspaces_label);

            var shortcuts_label = new Gtk.Label (_("Shortcuts")) {
                vexpand = true
            };

            var shortcuts_icon = new Gtk.Image.from_icon_name ("system-help-symbolic", Gtk.IconSize.MENU);

            var shortcuts_grid = new Gtk.Grid ();
            shortcuts_grid.add (shortcuts_icon);
            // shortcuts_grid.add (shortcuts_label);

            indicator_grid = new Gtk.Grid () {
                margin_top = 4,
                margin_bottom = 4,
                column_spacing = 4 + 6
            };
            indicator_grid.add (workspaces_grid);
            indicator_grid.add (shortcuts_grid);
        }

        visible = true;

        return indicator_grid;
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

/*
* SPDX-License-Identifier: GPL-2.0-or-later
* SPDX-FileCopyrightText: 2017-2023 elementary, Inc. (https://elementary.io)
*/

/**
 * PopoverMenuItem is a {@link Gtk.Button} subclass for use as a MenuItem in {@link Gtk.Popover}
 *
 * It will automatically call {@link Gtk.Popover.popdown} on its parent when clicked
 *
 * It contains a {@link Granite.AccelLabel} which will automatically show
 * accelerators for the {@link GLib.Action} assigned to #this
 *
 * @since 8.0.0
 */
[Version (since = "8.0.0")]
public class Wingpanel.PopoverMenuItem : Gtk.Button {
    /**
     * The label for the button
     */
    public string text {
        set {
            child = new Granite.AccelLabel (value) {
                action_name = this.action_name
            };

            update_property (Gtk.AccessibleProperty.LABEL, value, -1);
        }
    }

    class construct {
        set_css_name ("modelbutton");
    }

    public PopoverMenuItem () {}

    public PopoverMenuItem.with_text (string text) {
        Object (text: text);
    }

    construct {
        accessible_role = MENU_ITEM;

        clicked.connect (() => {
            var popover = (Gtk.Popover) get_ancestor (typeof (Gtk.Popover));
            if (popover != null) {
                popover.popdown ();
            }
        });
    }
}

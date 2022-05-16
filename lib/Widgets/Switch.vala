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

[Version (deprecated = true, deprecated_since = "3.0.0", replacement = "Granite.SwitchModelButton")]
public class Wingpanel.Widgets.Switch : Gtk.Bin {
    public bool active { get; set; }
    public string caption { owned get; set; }

    private Gtk.Label button_label;
    private Gtk.Switch button_switch;

    public Switch (string caption, bool active = false) {
        Object (caption: caption, active: active);
    }

    public Switch.with_mnemonic (string caption, bool active = false) {
        Object (caption: caption, active: active);
        button_label.set_text_with_mnemonic (caption);
        button_label.set_mnemonic_widget (this);
    }

    construct {
        button_switch = new Gtk.Switch ();
        button_switch.active = active;
        button_switch.halign = Gtk.Align.END;
        button_switch.hexpand = true;
        button_switch.valign = Gtk.Align.CENTER;

        button_label = new Gtk.Label (null);
        button_label.halign = Gtk.Align.START;

        var grid = new Gtk.Grid ();
        grid.column_spacing = 12;
        grid.attach (button_label, 0, 0);
        grid.attach (button_switch, 1, 0);

        var modelbutton = new Gtk.ModelButton ();
        modelbutton.get_child ().destroy ();
        modelbutton.add (grid);

        add (modelbutton);

        modelbutton.button_release_event.connect (() => {
            toggle_switch ();
            // Stop modelbutton from closing the popover
            return Gdk.EVENT_STOP;
        });

        bind_property ("active", button_switch, "active", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
        bind_property ("caption", button_label, "label", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
    }

    public new Gtk.Label get_label () {
        return button_label;
    }

    public Gtk.Switch get_switch () {
        return button_switch;
    }

    public void toggle_switch () {
        button_switch.activate ();
    }
}

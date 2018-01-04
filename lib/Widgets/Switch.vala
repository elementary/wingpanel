/*
 * Copyright (c) 2011-2015 Wingpanel Developers (http://launchpad.net/wingpanel)
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

public class Wingpanel.Widgets.Switch : Container {
    private Gtk.Label button_label;
    private Gtk.Switch button_switch;

    public new signal void switched ();

    public bool active {
        get {
            return button_switch.active;
        }
        set {
            button_switch.active = active;
        }
    }

    public bool use_mnemonic { get; construct; default = false; }

    public string caption {
        get {
            return button_label.label;
        }
        set {
            button_label.label = Markup.escape_text (value);
        }
    }

    public Switch (string caption, bool active = false) {
        Object (
            active: active,
            caption: caption
        );
    }

    public Switch.with_mnemonic (string caption, bool active = false) {
        Object (
            active: active,
            caption: caption,
            use_mnemonic: true
        );
    }

    construct {
        if (use_mnemonic) {
            button_label = new Gtk.Label.with_mnemonic (Markup.escape_text (caption));
            button_label.set_mnemonic_widget (this);
        } else {
            button_label = new Gtk.Label (Markup.escape_text (caption));
        }

        button_label.use_markup = true;
        button_label.halign = Gtk.Align.START;
        button_label.margin_start = 6;
        button_label.margin_end = 10;

        var button_switch = new Gtk.Switch ();
        button_switch.active = active;
        button_switch.halign = Gtk.Align.END;
        button_switch.margin_end = 6;
        button_switch.hexpand = true;

        content_widget.attach (button_label, 0, 0, 1, 1);
        content_widget.attach (button_switch, 1, 0, 1, 1);

        clicked.connect (() => {
            toggle_switch ();
        });

        button_switch.notify["active"].connect (() => {
            switched ();
        });
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

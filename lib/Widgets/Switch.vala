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
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

public class Wingpanel.Widgets.Switch : Container {
    private Gtk.Label button_label;

    private Gtk.Switch button_switch;

    public new signal void switched ();

    public Switch (string caption, bool active = false) {
        var content_widget = this.get_content_widget ();

        button_label = create_label_for_caption (caption);
        button_switch = create_switch (active);

        content_widget.attach (button_label, 0, 0, 1, 1);
        content_widget.attach (button_switch, 1, 0, 1, 1);

        connect_signals ();
    }

    public Switch.with_mnemonic (string caption, bool active = false) {
        var content_widget = this.get_content_widget ();

        button_label = create_label_for_caption (caption, true);
        button_switch = create_switch (active);

        content_widget.attach (button_label, 0, 0, 1, 1);
        content_widget.attach (button_switch, 1, 0, 1, 1);

        connect_signals ();
    }

    public void set_caption (string caption) {
        button_label.set_label (Markup.escape_text (caption));
    }

    public string get_caption () {
        return button_label.get_label ();
    }

    public void set_active (bool active) {
        button_switch.set_active (active);
    }

    public bool get_active () {
        return button_switch.get_active ();
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

    private Gtk.Label create_label_for_caption (string caption, bool use_mnemonic = false) {
        Gtk.Label label_widget;

        if (use_mnemonic) {
            label_widget = new Gtk.Label.with_mnemonic (Markup.escape_text (caption));
            label_widget.set_mnemonic_widget (this);
        } else {
            label_widget = new Gtk.Label (Markup.escape_text (caption));
        }

        label_widget.use_markup = true;
        label_widget.halign = Gtk.Align.START;
        label_widget.margin_start = 6;
        label_widget.margin_end = 10;

        return label_widget;
    }

    private Gtk.Switch create_switch (bool active) {
        var switch_widget = new Gtk.Switch ();
        switch_widget.active = active;
        switch_widget.halign = Gtk.Align.END;
        switch_widget.margin_end = 6;
        switch_widget.hexpand = true;

        return switch_widget;
    }

    private void connect_signals () {
        this.clicked.connect (() => {
            toggle_switch ();
        });

        button_switch.notify["active"].connect (() => {
            switched ();
        });
    }
}
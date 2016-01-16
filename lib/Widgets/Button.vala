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

public class Wingpanel.Widgets.Button : Container {
    private Gtk.Label button_label;

    private Gtk.Image button_image;

    public Button (string caption, string? icon_name = null) {
        var content_widget = this.get_content_widget ();

        button_image = create_image_for_icon_name (icon_name);
        button_label = create_label_for_caption (caption);

        content_widget.attach (button_image, 0, 0, 1, 1);
        content_widget.attach (button_label, 1, 0, 1, 1);
    }

    public Button.with_mnemonic (string caption, string? icon_name = null) {
        var content_widget = this.get_content_widget ();

        button_image = create_image_for_icon_name (icon_name);
        button_label = create_label_for_caption (caption, true);

        content_widget.attach (button_image, 0, 0, 1, 1);
        content_widget.attach (button_label, 1, 0, 1, 1);
    }

    public void set_caption (string caption) {
        button_label.set_label (Markup.escape_text (caption));
    }

    public string get_caption () {
        return button_label.get_label ();
    }

    public void set_icon (string? icon_name) {
        if (icon_name == null) {
            button_image.visible = false;
        } else {
            button_image.set_from_icon_name (icon_name, Gtk.IconSize.BUTTON);
            button_image.visible = true;
        }
    }

    public void set_pixbuf (Gdk.Pixbuf? pixbuf) {
        button_image.set_from_pixbuf (pixbuf);
        button_image.visible = pixbuf != null;
    }

    public Gdk.Pixbuf? get_pixbuf () {
        return button_image.get_pixbuf ();
    }

    public new Gtk.Label get_label () {
        return button_label;
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

    private Gtk.Image create_image_for_icon_name (string? icon_name) {
        var image = new Gtk.Image ();
        image.margin_start = 6;
        image.no_show_all = true;
        if (icon_name != null) {
            image.set_from_icon_name (icon_name, Gtk.IconSize.BUTTON);
            image.visible = true;
        } else {
            image.visible = false;
        }

        return image;
    }
}
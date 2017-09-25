/*
 * Copyright (c) 2011-2017 elementary LLC (https://elementary.io)
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

public class Wingpanel.Widgets.OverlayIcon : Gtk.Overlay {
    private Gtk.Image main_image;
    private Gtk.Image overlay_image;

    public OverlayIcon (string icon_name) {
        set_main_icon_name (icon_name);
    }

    public OverlayIcon.from_pixbuf (Gdk.Pixbuf pixbuf) {
        set_main_pixbuf (pixbuf);
    }

    construct {
        main_image = new Gtk.Image ();
        main_image.icon_size = 24;
        main_image.pixel_size = 24;

        overlay_image = new Gtk.Image ();
        overlay_image.icon_size = 24;
        overlay_image.pixel_size = 24;

        add (main_image);
        add_overlay (overlay_image);
    }

    public void set_main_pixbuf (Gdk.Pixbuf? pixbuf) {
        main_image.set_from_pixbuf (pixbuf);
    }

    public Gdk.Pixbuf? get_main_pixbuf () {
        return main_image.get_pixbuf ();
    }

    public void set_overlay_pixbuf (Gdk.Pixbuf? pixbuf) {
        overlay_image.set_from_pixbuf (pixbuf);
    }

    public Gdk.Pixbuf? get_overlay_pixbuf () {
        return overlay_image.get_pixbuf ();
    }

    public void set_main_icon_name (string icon_name) {
        main_image.icon_name = icon_name;
    }

    public string get_main_icon_name () {
        return main_image.icon_name;
    }

    public void set_overlay_icon_name (string icon_name) {
        overlay_image.icon_name = icon_name;
    }

    public string get_overlay_icon_name () {
        return overlay_image.icon_name;
    }

    public Gtk.Image get_main_image () {
        return main_image;
    }

    public Gtk.Image get_overlay_image () {
        return overlay_image;
    }
}

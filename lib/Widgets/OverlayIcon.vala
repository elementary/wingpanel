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

public class Wingpanel.Widgets.OverlayIcon : Gtk.Overlay {
    private Gtk.Image main_image;

    private Gtk.Image overlay_image;

    public OverlayIcon (string icon_name) {
        add_images ();

        set_main_icon_name (icon_name);
    }

    public OverlayIcon.from_pixbuf (Gdk.Pixbuf pixbuf) {
        add_images ();

        set_main_pixbuf (pixbuf);
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
        main_image.set_from_icon_name (icon_name, Gtk.IconSize.LARGE_TOOLBAR);
        main_image.icon_size = 24;
        main_image.pixel_size = 24;
    }

    public string get_main_icon_name () {
        string icon_name;
        Gtk.IconSize size;

        main_image.get_icon_name (out icon_name, out size);

        return icon_name;
    }

    public void set_overlay_icon_name (string icon_name) {
        overlay_image.set_from_icon_name (icon_name, Gtk.IconSize.LARGE_TOOLBAR);
        overlay_image.icon_size = 24;
        overlay_image.pixel_size = 24;
    }

    public string get_overlay_icon_name () {
        string icon_name;
        Gtk.IconSize size;

        overlay_image.get_icon_name (out icon_name, out size);

        return icon_name;
    }

    public Gtk.Image get_main_image () {
        return main_image;
    }

    public Gtk.Image get_overlay_image () {
        return overlay_image;
    }

    private void add_images () {
        main_image = new Gtk.Image ();
        overlay_image = new Gtk.Image ();

        this.add (main_image);
        this.add_overlay (overlay_image);
    }
}
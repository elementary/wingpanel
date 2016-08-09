/*
 * Copyright (c) 2011-2015 Ikey Doherty <ikey@solus-project.com>
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

public class Wingpanel.Services.PopoverManager : Object {
    private HashTable<Gtk.Widget? , Gtk.Popover? > widgets;
    private HashTable<Gtk.Popover? , Wingpanel.Widgets.IndicatorEntry? > popovers;

    private unowned Wingpanel.PanelWindow? owner;
    private unowned Gtk.Popover? visible_popover = null;

    private bool grabbed = false;
    private bool mousing = false;

    public PopoverManager (Wingpanel.PanelWindow? owner) {
        this.owner = owner;

        widgets = new HashTable<Gtk.Widget? , Gtk.Popover? > (direct_hash, direct_equal);
        popovers = new HashTable<Gtk.Popover? , Wingpanel.Widgets.IndicatorEntry? > (direct_hash, direct_equal);

        owner.focus_out_event.connect ((e) => {
            if (mousing) {
                return Gdk.EVENT_PROPAGATE;
            }

            if (visible_popover != null && e.window == null) {
                hide_popover ();
            }

            return Gdk.EVENT_PROPAGATE;
        });

        owner.button_press_event.connect ((w, e) => {
            if (!grabbed) {
                return Gdk.EVENT_PROPAGATE;
            }

            Gtk.Allocation allocation;
            visible_popover.get_allocation (out allocation);

            if ((e.x < allocation.x || e.x > allocation.x + allocation.width) || (e.y < allocation.y || e.y > allocation.y + allocation.height)) {
                hide_popover ();
                owner.set_expanded (false);
            }

            return Gdk.EVENT_STOP;
        });

        owner.add_events (Gdk.EventMask.POINTER_MOTION_MASK | Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.BUTTON_PRESS_MASK);
    }

    public unowned Gtk.Popover? get_visible_popover () {
        return visible_popover;
    }

    public void set_popover_visible (string code_name, bool visible) {
        popovers.@foreach ((popover, indicator_entry) => {
            if (indicator_entry.base_indicator.code_name == code_name) {
                if (visible) {
                    if (visible_popover != null) {
                        hide_popover ();
                    }
                    popover.show_all ();
                } else {
                    popover.hide ();
                }

                return;
            }
        });
    }

    public void toggle_popover_visible (string code_name) {
        popovers.@foreach ((popover, indicator_entry) => {
            if (indicator_entry.base_indicator.code_name == code_name) {
                if (popover.get_visible ()) {
                    popover.hide ();
                } else {
                    if (visible_popover != null) {
                        hide_popover ();
                    }
                    popover.show_all ();
                }

                return;
            }
        });
    }

    private void hide_popover () {
        visible_popover.hide ();
        make_modal (visible_popover, false);
        visible_popover = null;
    }

    private void make_modal (Gtk.Popover? pop, bool modal = true) {
        if (pop == null || pop.get_window () == null || mousing) {
            return;
        }

        if (modal) {
            if (grabbed) {
                return;
            }

            Gtk.grab_add (owner);
            owner.set_focus (null);
            pop.grab_focus ();
            grabbed = true;
        } else {
            if (!grabbed) {
                return;
            }

            Gtk.grab_remove (owner);
            owner.grab_focus ();
            grabbed = false;
        }
    }

    public void close () {
        if (visible_popover != null) {
            hide_popover ();
            owner.set_expanded (false);
        }
    }

    public void unregister_popover (Gtk.Widget? widg) {
        if (!widgets.contains (widg)) {
            return;
        }

        var popover = widgets[widg];
        popovers.remove (popover);
        widgets.remove (widg);
    }

    public void register_popover (Wingpanel.Widgets.IndicatorEntry? widg, Gtk.Popover? popover) {
        if (widgets.contains (widg)) {
            return;
        }

        widg.can_focus = false;

        popover.show.connect ((p) => {
            widg.base_indicator.opened ();
            owner.set_expanded (true);
            owner.present ();
            this.visible_popover = p as Gtk.Popover;
            make_modal (this.visible_popover);
        });

        popover.closed.connect ((p) => {
            if (!mousing && grabbed) {
                make_modal (p, false);
                popovers[visible_popover].base_indicator.closed ();
                visible_popover.hide ();
                visible_popover = null;
                owner.set_expanded (false);
            }
        });

        popover.leave_notify_event.connect ((e) => {
            Gtk.Allocation allocation;
            popover.get_allocation (out allocation);

            if (e.mode != Gdk.CrossingMode.NORMAL && e.subwindow == null) {
                hide_popover ();
            }

            return Gdk.EVENT_PROPAGATE;
        });

        widg.enter_notify_event.connect ((w, e) => {
            owner.set_expanded (true);

            if (mousing) {
                return Gdk.EVENT_PROPAGATE;
            }

            if (grabbed) {
                if (widgets.contains (w)) {
                    if (visible_popover != widgets[w] && visible_popover != null) {
                        /* Hide current popover, re-open next */
                        mousing = true;

                        visible_popover.hide ();
                        popovers[visible_popover].base_indicator.closed ();

                        visible_popover = widgets[w];

                        visible_popover.show_all ();
                        owner.set_focus (null);
                        visible_popover.grab_focus ();

                        mousing = false;
                    }
                }

                return Gdk.EVENT_STOP;
            }

            return Gdk.EVENT_PROPAGATE;
        });

        widg.leave_notify_event.connect (() => {
            if (visible_popover == null) {
                owner.set_expanded (false);
            }

            return Gdk.EVENT_PROPAGATE;
        });

        popover.notify["visible"].connect (() => {
            if (mousing || grabbed) {
                return;
            }

            if (!popover.get_visible ()) {
                make_modal (visible_popover, false);
                visible_popover = null;
            }
        });

        popover.destroy.connect ((w) => {
            widgets.remove (w);
        });

        popover.modal = false;
        widgets.insert (widg, popover);
        popovers.insert (popover, widg);
    }
}
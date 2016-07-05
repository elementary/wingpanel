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

public class Wingpanel.Widgets.IndicatorEntry : Gtk.MenuItem {
    private Gtk.Widget display_widget;
    private Gtk.Widget indicator_widget;

    private Gtk.Revealer revealer;

    private IndicatorPopover popover;
    public Indicator base_indicator;
    public IndicatorMenuBar? menu_bar;

    public IndicatorEntry (Indicator base_indicator, Services.PopoverManager popover_manager) {
        this.base_indicator = base_indicator;
        this.halign = Gtk.Align.START;
        this.get_style_context ().add_class (StyleClass.COMPOSITED_INDICATOR);
        this.name = base_indicator.code_name + "/entry";

        display_widget = base_indicator.get_display_widget ();

        if (display_widget == null) {
            return;
        }

        display_widget.margin_start = 4;
        display_widget.margin_end = 4;

        revealer = new Gtk.Revealer ();
        this.add (revealer);
        revealer.add (display_widget);

        indicator_widget = base_indicator.get_widget ();

        if (indicator_widget == null) {
            this.button_press_event.connect ((e) => {
                popover_manager.close ();
                display_widget.button_press_event (e);

                return Gdk.EVENT_PROPAGATE;
            });
            set_reveal (base_indicator.visible);

            return;
        }

        popover = new IndicatorPopover (base_indicator.code_name, indicator_widget);
        popover.relative_to = this;

        if (base_indicator.visible) {
            popover_manager.register_popover (this, popover);
        }

        base_indicator.close.connect (() => {
            popover_manager.close ();
        });

        base_indicator.notify["visible"].connect (() => {
            if (menu_bar != null) {
                /* order will be changed so close all open popovers */
                popover_manager.close ();

                if (base_indicator.visible) {
                    popover_manager.register_popover (this, popover);
                    menu_bar.apply_new_order ();
                    set_reveal (base_indicator.visible);
                } else {
                    set_reveal (base_indicator.visible);
                    popover_manager.unregister_popover (this);

                    Timeout.add (revealer.get_transition_duration (), () => {
                        menu_bar.apply_new_order ();

                        return false;
                    });
                }
            } else {
                set_reveal (base_indicator.visible);
            }
        });

        add_events (Gdk.EventMask.SCROLL_MASK);

        this.scroll_event.connect ((e) => {
            display_widget.scroll_event (e);

            return Gdk.EVENT_PROPAGATE;
        });

        this.touch_event.connect ((e) => {
            if (e.type == Gdk.EventType.TOUCH_BEGIN) {
                if (popover.get_visible ()) {
                    popover.hide ();
                } else {
                    popover.show_all ();
                }

                return Gdk.EVENT_STOP;
            }

            return Gdk.EVENT_PROPAGATE;
        });

        this.button_press_event.connect ((e) => {
            if ((e.button == Gdk.BUTTON_PRIMARY || e.button == Gdk.BUTTON_SECONDARY)
                && e.type == Gdk.EventType.BUTTON_PRESS) {
                if (popover.get_visible ()) {
                    popover.hide ();
                } else {
                    popover.show_all ();
                }

                return Gdk.EVENT_STOP;
            }

            /* Call button press on the indicator display widget */
            display_widget.button_press_event (e);

            return Gdk.EVENT_PROPAGATE;
        });

        set_reveal (base_indicator.visible);
    }

    public void set_transition_type (Gtk.RevealerTransitionType transition_type) {
        revealer.set_transition_type (transition_type);
    }

    private void set_reveal (bool reveal) {
        if (!reveal && popover.get_visible ()) {
            popover.hide ();
        }

        revealer.set_reveal_child (reveal);
    }
}

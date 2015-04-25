/*-
 * Copyright (c) 2015 Wingpanel Developers (http://launchpad.net/wingpanel)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Library General Public License as published by
 * the Free Software Foundation, either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

public class Wingpanel.Services.PopoverManager : Object {
	HashTable<Gtk.Widget?, Gtk.Popover?> widgets;

	unowned Wingpanel.PanelWindow? owner;
	unowned Gtk.Popover? visible_popover = null;

	bool grabbed = false;
	bool mousing = false;

	public PopoverManager (Wingpanel.PanelWindow? owner) {
		this.owner = owner;

		widgets = new HashTable<Gtk.Widget?, Gtk.Popover?> (direct_hash, direct_equal);

		owner.focus_out_event.connect (() => {
			if (mousing)
				return Gdk.EVENT_PROPAGATE;

			if (visible_popover != null)
				hide_popover ();

			return Gdk.EVENT_PROPAGATE;
		});

		owner.button_press_event.connect ((w,e) => {
			if (!grabbed)
				return Gdk.EVENT_PROPAGATE;

			Gtk.Allocation allocation;
			visible_popover.get_allocation (out allocation);

			if ((e.x < allocation.x || e.x > allocation.x + allocation.width) || (e.y < allocation.y || e.y > allocation.y + allocation.height))
				hide_popover ();

			return Gdk.EVENT_STOP;
		});

		owner.add_events (Gdk.EventMask.POINTER_MOTION_MASK | Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.BUTTON_PRESS_MASK);
	}

	private void hide_popover () {
		visible_popover.hide ();
		make_modal (visible_popover, false);
		visible_popover = null;
	}

	void make_modal (Gtk.Popover? pop, bool modal = true) {
		if (pop == null || pop.get_window () == null || mousing)
			return;

		if (modal) {
			if (grabbed)
				return;

			Gtk.grab_add (owner);
			owner.set_focus (null);
			pop.grab_focus ();
			grabbed = true;
		} else {
			if (!grabbed)
				return;

			Gtk.grab_remove (owner);
			owner.grab_focus ();
			grabbed = false;
		}
	}

	public void unregister_popover (Gtk.Widget? widg) {
		if (!widgets.contains (widg))
			return;

		widgets.remove (widg);
	}

	public void register_popover (Gtk.Widget? widg, Gtk.Popover? popover)
	{
		if (widgets.contains (widg))
			return;

		if (widg is Gtk.MenuItem)
			(widg as Gtk.MenuItem).can_focus = false;

		popover.map.connect ((p) => {
			owner.set_expanded (true);
			this.visible_popover = p as Gtk.Popover;
			make_modal (this.visible_popover);
		});

		popover.closed.connect ((p) => {
			if (!mousing && grabbed) {
				make_modal (p, false);
				visible_popover = null;
			}
		});

		widg.enter_notify_event.connect ((w,e) => {
			if (mousing)
				return Gdk.EVENT_PROPAGATE;

			if (grabbed) {
				if (widgets.contains (w)) {
					if (visible_popover != widgets[w] && visible_popover != null) {
						// Hide current popover, re-open next
						mousing = true;

						visible_popover.hide ();

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

		popover.notify["visible"].connect (() => {
			if (mousing || grabbed)
				return;

			if (!popover.get_visible ()) {
				make_modal (visible_popover, false);
				visible_popover = null;
				owner.set_expanded (false);
			}
		});

		popover.destroy.connect ((w) => {
			widgets.remove (w);
		});

		popover.modal = false;
		widgets.insert (widg, popover);
	}
}

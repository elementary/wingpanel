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

public class Sample.Indicator : Wingpanel.Indicator {
	private Gtk.Stack display_widget;
	private Wingpanel.Widgets.DynamicIcon dynamic_icon;

	private KeyboardInput keyboard_input;

	private Gtk.Grid main_grid;

	private Wingpanel.Widgets.IndicatorButton loading_button;
	private Wingpanel.Widgets.IndicatorButton close_button;
	private Wingpanel.Widgets.IndicatorButton keyboard_button;
	private Wingpanel.Widgets.IndicatorButton label_button;
	private Wingpanel.Widgets.IndicatorSwitch test_switch;

	private Wingpanel.Widgets.IndicatorButton next_icon_button;

	private Notify.Notification notification;

	private int current_icon = 0;
	private double volume = 0.5;
	private string[] icon_names = {"system-shutdown-symbolic", "audio-volume-medium-symbolic", "audio-volume-muted-symbolic", "network-cellular-signal-excellent-symbolic", "battery-empty-symbolic"};

	public Indicator () {
		Object (code_name: "sample-indicator",
				display_name: _("Sample Indicator"),
				description:_("Does nothing, but it is cool!"));
		Notify.init ("wingpanel-indicator-sample");
		this.notification = new Notify.Notification ("indicator-sound", "", "");
		this.notification.set_hint ("x-canonical-private-synchronous", new Variant.string ("indicator-sound"));

		// Indicator should be visible at startup
		this.visible = true;
	}

	public override Gtk.Widget get_display_widget () {
		if (display_widget == null) {
			display_widget = new Gtk.Stack ();
			dynamic_icon = new Wingpanel.Widgets.DynamicIcon (icon_names[current_icon]);
			display_widget.add_named (dynamic_icon, "dynamic_icon");
			dynamic_icon.button_press_event.connect ((e) => {
				if (e.button == Gdk.BUTTON_MIDDLE) {
					current_icon++;

					if (current_icon >= icon_names.length)
						current_icon = 0;

					dynamic_icon.set_icon_name (icon_names[current_icon]);
					return Gdk.EVENT_STOP;
				}

				return Gdk.EVENT_PROPAGATE;
			});
			// change volume on scroll
			dynamic_icon.scroll_event.connect ((e) => {
				int dir = 0;
				if (e.direction == Gdk.ScrollDirection.UP) {
					dir = 1;
				} else if (e.direction == Gdk.ScrollDirection.DOWN) {
					dir = -1;
				}
				double v = this.volume + 0.06 * dir;
				this.volume = v.clamp (0.0, 1.0);
				if (this.notification != null && v >= -0.05 && v <= 1.05) {
					string icon;
					if (v <= 0.0)
						icon = "notification-audio-volume-off";
					else if (v <= 0.3)
						icon = "notification-audio-volume-low";
					else if (v <= 0.7)
						icon = "notification-audio-volume-medium";
					else
						icon = "notification-audio-volume-high";

					this.notification.update ("indicator-sound", "", icon);
					this.notification.set_hint ("value", new Variant.int32 (
						((int32) (1.0 * 100 * v / 1.0)).
							clamp (-1, ((int)1.0 * 100) + 1)));
					try {
						this.notification.show ();
					}
					catch (Error e) {
						warning ("unable to show notification: %s", e.message);
					}
				}
				return Gdk.EVENT_STOP;
			});

			keyboard_input = new KeyboardInput ();
			display_widget.add_named (keyboard_input, "keyboard_input");

			var label = new Gtk.Label ("Lbl");
			display_widget.add_named (label, "label");


		}

		return display_widget;
	}

	public override Gtk.Widget get_widget () {
		if (main_grid == null) {
			main_grid = new Gtk.Grid ();

			var loading = false;
			loading_button = new Wingpanel.Widgets.IndicatorButton ("Im doing something...");
			loading_button.clicked.connect (() => {
				if (!loading) {
					dynamic_icon.start_loading ();
					loading_button.set_caption ("Stop");
					loading = true;
				} else {
					dynamic_icon.stop_loading ();
					loading_button.set_caption ("Im doing something...");
					loading = false;
				}
			});

			main_grid.attach (loading_button, 0, 0, 1, 1);

			next_icon_button = new Wingpanel.Widgets.IndicatorButton ("Next Icon");
			next_icon_button.clicked.connect (() => {
				current_icon++;

				if (current_icon >= icon_names.length)
					current_icon = 0;

				dynamic_icon.set_icon_name (icon_names[current_icon]);
			});

			main_grid.attach (next_icon_button, 0, 1, 1, 1);

			main_grid.attach (new Wingpanel.Widgets.IndicatorSeparator (), 0, 2, 1, 1);

			test_switch = new Wingpanel.Widgets.IndicatorSwitch ("Visible", true);

			test_switch.get_switch ().notify["active"].connect (() => {
				if (!test_switch.get_switch ().active) {
					visible = false;

					Timeout.add (2000, () => {
						test_switch.get_switch ().set_active (true);
						visible = true;

						return false;
					});
				}
			});

			main_grid.attach (test_switch, 0, 3, 1, 1);

			main_grid.attach (new Wingpanel.Widgets.IndicatorSeparator (), 0, 4, 1, 1);

			string[] abc_big = new string[] {"A","B","C","D","E","F","G","H","I","J"};
			string[] abc_small = new string[] {"a","b","c","d","e","f","g","h","i","j"};
			keyboard_button = new Wingpanel.Widgets.IndicatorButton ("Keyboard Input Widget");
			keyboard_button.clicked.connect (() => {
				display_widget.set_visible_child (keyboard_input);
				keyboard_input.set_lang ("%s%s".printf (abc_big[Random.int_range (0,9)],
					abc_small[Random.int_range (0,9)]));
			});

			main_grid.attach (keyboard_button, 0, 5, 1, 1);

			label_button = new Wingpanel.Widgets.IndicatorButton ("Show Label");
			label_button.clicked.connect (() => {
				display_widget.set_visible_child_name ("label");
			});

			main_grid.attach (label_button, 0, 6, 1, 1);


			main_grid.attach (new Wingpanel.Widgets.IndicatorSeparator (), 0, 7, 1, 1);

			close_button = new Wingpanel.Widgets.IndicatorButton ("Show Settings");
			close_button.clicked.connect (() => {
				var cmd = new Granite.Services.SimpleCommand ("/usr/bin", "/usr/bin/switchboard");
				cmd.run ();
				close ();
			});

			main_grid.attach (close_button, 0, 8, 1, 1);


		}

		return main_grid;
	}

	public override void opened () {
		// Use this method to get some extra information while displaying the indicator
		print ("opened\n");
	}

	public override void closed () {
		// Your stuff isn't shown anymore, now you can free some RAM, stop timers or anything else...
		print ("closed\n");
	}
}

public Wingpanel.Indicator get_indicator (Module module) {
	debug ("Activating Sample Indicator");
	var indicator = new Sample.Indicator ();
	return indicator;
}

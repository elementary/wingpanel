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

public class Wingpanel.PanelWindow : Gtk.Window {
	private Widgets.Panel panel;

	public PanelWindow () {
		this.decorated = false;
		this.resizable = false;
		this.skip_taskbar_hint = true;
		this.type_hint = Gdk.WindowTypeHint.DOCK;
		this.get_style_context ().add_class ("panel-window");

		this.screen.size_changed.connect (update_panel_size);
		this.screen.monitors_changed.connect (update_panel_size);

		update_panel_size ();

		panel = new Widgets.Panel ();

		this.add (panel);
	}

	private void update_panel_size () {
		Gdk.Rectangle monitor_dimensions;
		this.screen.get_monitor_geometry (this.screen.get_primary_monitor (), out monitor_dimensions);

		this.set_size_request (monitor_dimensions.width, -1);
	}
}

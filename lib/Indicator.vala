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

public abstract class Wingpanel.Indicator : GLib.Object {
	public static const string APP_LAUNCHER = "app-launcher";
	public static const string SESSION = "session";
	public static const string DATETIME = "datetime";
	public static const string NETWORK = "network";
	public static const string MESSAGES = "messages";
	public static const string SOUND = "sound";
	public static const string POWER = "power";
	public static const string SYNC = "sync";
	public static const string PRINTER = "printer";
	public static const string BLUETOOTH = "bluetooth";
	public static const string KEYBOARD = "keyboard";

	public string code_name { get; construct; }

	public string display_name { get; construct; }

	public string description { get; construct; }

	public bool visible { get; set; default=false; }

	public abstract Gtk.Widget get_display_widget ();

	public abstract Gtk.Widget get_widget ();

	public abstract void opened ();

	public abstract void closed ();

	public signal void close ();
}

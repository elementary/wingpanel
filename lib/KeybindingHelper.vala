/*
 * Copyright 2026 elementary, Inc. (https://elementary.io)
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * Authored by: Leonhard Kargl <leo.kargl@proton.me>
 */

public class Wingpanel.KeybindingHelper : Object {
    private static Once<KeybindingHelper> instance;

    private ShellKeyGrabber? shell_key_grabber = null;

    private Gee.ArrayList<Keybinding> keybindings;

    public static unowned KeybindingHelper get_default () {
        return instance.once (() => new KeybindingHelper ());
    }

    construct {
        keybindings = new Gee.ArrayList<Keybinding> ();

        try {
            shell_key_grabber = Bus.get_proxy_sync (SESSION, "org.gnome.Shell", "/org/gnome/Shell");
        } catch (Error e) {
            warning ("Failed to get key grabber proxy: %s", e.message);
        }
    }

    public void add_keybinding (string name, Settings settings, KeybindingAction action) requires (shell_key_grabber != null) {
        var binding = new Keybinding (name, settings, action, shell_key_grabber);
        keybindings.add (binding);
    }

    public void show_osd (HashTable<string, Variant> parameters) requires (shell_key_grabber != null) {
        try {
            shell_key_grabber.show_osd (parameters);
        } catch (Error e) {
            warning ("Failed to show OSD: %s", e.message);
        }
    }

    public class NamedAction : Object, KeybindingAction {
        public Gtk.Widget widget { get; construct; }
        public string name { get; construct; }
        public Variant? target { get; construct; }

        public NamedAction (Gtk.Widget widget, string name, Variant? target = null) {
            Object (widget: widget, name: name, target: target);
        }

        internal void activate () {
            widget.activate_action_variant (name, target);
        }
    }

    public class SignalAction : Object, KeybindingAction {
        public signal void activated ();

        internal void activate () {
            activated ();
        }
    }

    public interface KeybindingAction : Object {
        internal abstract void activate ();
    }

    private class Keybinding : Object {
        public string name { get; construct; }
        public Settings settings { get; construct; }
        public KeybindingAction action { get; construct; }
        public ShellKeyGrabber shell_key_grabber { get; construct; }

        private uint[] action_ids = {};

        public Keybinding (string name, Settings settings, KeybindingAction action, ShellKeyGrabber shell_key_grabber) {
            Object (name: name, settings: settings, action: action, shell_key_grabber: shell_key_grabber);
        }

        construct {
            shell_key_grabber.accelerator_activated.connect (on_accelerator_activated);

            settings.changed.connect (on_settings_changed);
            grab ();
        }

        private void on_accelerator_activated (uint action_id, HashTable<string, Variant> parameters) {
            if (action_id in action_ids) {
                action.activate ();
            }
        }

        private void on_settings_changed (string key) {
            if (key == name) {
                grab ();
            }
        }

        private void grab () {
            if (action_ids.length > 0) {
                ungrab ();
            }

            action_ids = {};

            var accelerators = settings.get_strv (name);
            foreach (var accelerator in accelerators) {
                try {
                    action_ids += shell_key_grabber.grab_accelerator (accelerator, NONE, NONE);
                } catch (Error e) {
                    warning ("Failed to grab keybinding '%s' for accelerator '%s': %s", name, accelerator, e.message);
                }
            }
        }

        private void ungrab () {
            try {
                shell_key_grabber.ungrab_accelerators (action_ids);
            } catch (Error e) {
                warning ("Failed to ungrab keybinding '%s': %s", name, e.message);
            }
        }
    }

    [Flags]
    private enum ActionMode {
        NONE = 0,
        NORMAL = 1 << 0,
        OVERVIEW = 1 << 1,
        LOCK_SCREEN = 1 << 2,
        UNLOCK_SCREEN = 1 << 3,
        LOGIN_SCREEN = 1 << 4,
        SYSTEM_MODAL = 1 << 5,
        LOOKING_GLASS = 1 << 6,
        POPUP = 1 << 7,
    }

    [Flags]
    private enum KeyBindingFlags {
        NONE = 0,
        PER_WINDOW = 1 << 0,
        BUILTIN = 1 << 1,
        IS_REVERSED = 1 << 2,
        NON_MASKABLE = 1 << 3,
        IGNORE_AUTOREPEAT = 1 << 4,
    }

    [DBus (name = "org.gnome.Shell")]
    private interface ShellKeyGrabber : GLib.Object {
        public signal void accelerator_activated (uint action, GLib.HashTable<string, GLib.Variant> parameters_dict);

        public abstract uint grab_accelerator (string accelerator, ActionMode mode_flags, KeyBindingFlags grab_flags) throws GLib.DBusError, GLib.IOError;
        public abstract bool ungrab_accelerators (uint[] actions) throws GLib.DBusError, GLib.IOError;

        [DBus (name = "ShowOSD")]
        public abstract void show_osd (GLib.HashTable<string, GLib.Variant> parameters_dict) throws GLib.DBusError, GLib.IOError;
    }
}

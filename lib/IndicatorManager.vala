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
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 */

public class Wingpanel.IndicatorManager : GLib.Object {
    private static Wingpanel.IndicatorManager? indicator_manager = null;

    public static unowned IndicatorManager get_default () {
        if (indicator_manager == null) {
            indicator_manager = new IndicatorManager ();
        }

        return indicator_manager;
    }

    /**
     * The type of the server displaying the indicator.
     */
    public enum ServerType {
        SESSION,
        GREETER;

        public string restrictions_file_name () {
            switch (this) {
                case SESSION :

                    return "default";

                case GREETER:

                    return "greeter";

                default:
                    assert_not_reached ();
            }
        }
    }

    /**
     * Called when a new indicator was added.
     */
    public signal void indicator_added (Wingpanel.Indicator indicator);

    /**
     * Called when an indicator was removed.
     */
    public signal void indicator_removed (Wingpanel.Indicator indicator);

    /**
     * Place the files in /etc/wingpanel.d/ or ~/.config/wingpanel.d/
     * default.forbidden, greeter.allowed or combinations of it.
     */
    private Gee.HashSet<string> forbidden_indicators;
    private Gee.HashSet<string> allowed_indicators;

    [CCode (has_target = false)]
    private delegate Wingpanel.Indicator? RegisterPluginFunction (Module module, ServerType server_type);

    private Gee.HashMap<string, Wingpanel.Indicator> indicators;

    private FileMonitor? monitor = null;

    private FileMonitor? root_restrictions_monitor = null;
    private FileMonitor? user_restrictions_monitor = null;

    private ServerType server_type;

    private IndicatorManager () {
        indicators = new Gee.HashMap<string, Wingpanel.Indicator> ();
        forbidden_indicators = new Gee.HashSet<string> ();
        allowed_indicators = new Gee.HashSet<string> ();
    }

    /**
     * Run this method to initialize the indicator manager.
     *
     * @param server_type The server the indicators will be displayed on.
     */
    public void initialize (ServerType server_type) {
        this.server_type = server_type;

        /* load inclusion/exclusion lists */
        var root_restrictions_folder = File.new_for_path ("/etc/wingpanel.d/");
        var user_restrictions_folder = File.new_for_path (Path.build_filename (Environment.get_user_config_dir (), "wingpanel.d"));

        try {
            root_restrictions_monitor = root_restrictions_folder.monitor_directory (FileMonitorFlags.NONE, null);
            root_restrictions_monitor.changed.connect ((file, trash, event) => {
                reload_restrictions (root_restrictions_folder, user_restrictions_folder);
            });
            user_restrictions_monitor = user_restrictions_folder.monitor_directory (FileMonitorFlags.NONE, null);
            user_restrictions_monitor.changed.connect ((file, trash, event) => {
                reload_restrictions (root_restrictions_folder, user_restrictions_folder);
            });

            load_restrictions (root_restrictions_folder);
            load_restrictions (user_restrictions_folder);
        } catch (Error error) {
            warning ("Error while reading restrictions files: %s\n", error.message);
        }

        /* load indicators */
        var base_folder = File.new_for_path (Build.INDICATORS_DIR);

        try {
            monitor = base_folder.monitor_directory (FileMonitorFlags.NONE, null);
            monitor.changed.connect ((file, trash, event) => {
                var plugin_path = file.get_path ();

                if (event == FileMonitorEvent.CHANGES_DONE_HINT) {
                    /*
                     * FIXME: Reloading the plugin does not update the indicator and only registers it again.
                     * See module.make_resident ()
                     */
                    load (plugin_path);
                } else if (event == FileMonitorEvent.DELETED) {
                    var indicator = indicators[plugin_path];
                    if (indicator != null) {
                        deregister_indicator (plugin_path, indicator);
                    }
                }
            });
        } catch (Error error) {
            warning ("Creating monitor for %s failed: %s\n", base_folder.get_path (), error.message);
        }

        find_plugins (base_folder);
    }

    private void load (string path) {
        if (!Module.supported ()) {
            error ("Wingpanel is not supported by this system!");
        }

        if (!path.has_suffix (GLib.Module.SUFFIX)) {
            return;
        } else if (indicators.has_key (path)) {
            return;
        } else if (check_forbidden_indicators (path)) {
            debug ("Indicator %s will not be loaded since it is explicitly forbidden", path);

            return;
        } else if (!check_allowed_indicators (path)) {
            debug ("Indicator %s will not be loaded since it is not enabled", path);

            return;
        }

        Module module = Module.open (path, ModuleFlags.BIND_LAZY);

        if (module == null) {
            critical (Module.error ());

            return;
        }

        void* function;

        if (!module.symbol ("get_indicator", out function)) {
            return;
        }

        if (function == null) {
            critical ("get_indicator () not found in %s", path);

            return;
        }

        RegisterPluginFunction register_plugin = (RegisterPluginFunction)function;
        Wingpanel.Indicator? indicator = register_plugin (module, server_type);

        if (indicator == null) {
            debug ("Unknown plugin type for %s or indicator is hidden on this server!", path);

            return;
        }

        module.make_resident ();
        register_indicator (path, indicator);
    }

    private void find_plugins (File base_folder) {
        FileInfo file_info = null;

        try {
            var enumerator = base_folder.enumerate_children (FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE + "," + FileAttribute.STANDARD_CONTENT_TYPE, 0);

            while ((file_info = enumerator.next_file ()) != null) {
                var file = base_folder.get_child (file_info.get_name ());

                if (file_info.get_file_type () == FileType.REGULAR && GLib.ContentType.equals (file_info.get_content_type (), "application/x-sharedlib")) {
                    load (file.get_path ());
                } else if (file_info.get_file_type () == FileType.DIRECTORY) {
                    find_plugins (file);
                }
            }
        } catch (Error error) {
            warning ("Unable to scan indicators folder %s: %s\n", base_folder.get_path (), error.message);
        }
    }

    private bool check_forbidden_indicators (string path) {
        foreach (var indicator_file_name in forbidden_indicators) {
            if (path.has_suffix (indicator_file_name)) {
                return true;
            }
        }

        return false;
    }

    private bool check_allowed_indicators (string path) {
        if (allowed_indicators.size == 0) {
            return true;
        }

        foreach (var indicator_file_name in allowed_indicators) {
            if (path.has_suffix (indicator_file_name)) {
                return true;
            }
        }

        return false;
    }

    private void reload_restrictions (File root_restrictions_folder, File user_restrictions_folder) {
        forbidden_indicators.clear ();
        allowed_indicators.clear ();
        load_restrictions (root_restrictions_folder);
        load_restrictions (user_restrictions_folder);

        indicators.@foreach ((entry) => {
            if (check_forbidden_indicators (entry.key)) {
                deregister_indicator (entry.key, entry.value);
            } else if (!check_allowed_indicators (entry.key)) {
                deregister_indicator (entry.key, entry.value);
            }

            return true;
        });
        find_plugins (File.new_for_path (Build.INDICATORS_DIR));
    }

    private void load_restrictions (File restrictions_folder) {
        if (!restrictions_folder.query_exists ()) {
            return;
        }

        FileInfo file_info = null;

        try {
            var enumerator = restrictions_folder.enumerate_children (FileAttribute.STANDARD_NAME, 0);

            while ((file_info = enumerator.next_file ()) != null) {
                unowned string file_name = file_info.get_name ();
                if (!file_name.contains (server_type.restrictions_file_name ())) {
                    continue;
                }

                var file = restrictions_folder.get_child (file_name);

                if (file_name.has_suffix (".allowed")) {
                    foreach (var entry in get_restrictions_from_file (file)) {
                        allowed_indicators.add (entry);
                    }
                } else if (file_name.has_suffix (".forbidden")) {
                    foreach (var entry in get_restrictions_from_file (file)) {
                        forbidden_indicators.add (entry);
                    }
                } else if (file_name.has_suffix (".whitelist")) {
                    critical ("Using .whitelist files is deprecated and will be removed in next version, please use .allowed instead");
                    foreach (var entry in get_restrictions_from_file (file)) {
                        allowed_indicators.add (entry);
                    }
                } else if (file_name.has_suffix (".blacklist")) {
                    critical ("Using .blacklist files is deprecated and will be removed in next version, please use .forbidden instead");
                    foreach (var entry in get_restrictions_from_file (file)) {
                        forbidden_indicators.add (entry);
                    }
                }
            }
        } catch (Error error) {
            warning ("Unable to scan restrictions folder %s: %s\n", restrictions_folder.get_path (), error.message);
        }
    }

    private string[] get_restrictions_from_file (File file) {
        var restrictions = new string[] {};

        if (file.query_exists ()) {
            try {
                var dis = new DataInputStream (file.read ());
                string line = null;

                while ((line = dis.read_line ()) != null) {
                    if (line.strip () != "") {
                        restrictions += line;
                    }
                }
            } catch (Error error) {
                warning ("Unable to load restrictions file %s: %s\n", file.get_basename (), error.message);
            }
        }

        return restrictions;
    }

    /**
     * Register a new indicator.
     *
     * @param path The path to the plugin file. (Used to identify the indicator)
     * @param indicator The indicator.
     */
    public void register_indicator (string path, Wingpanel.Indicator indicator) {
        debug ("%s registered", indicator.code_name);

        var deregister_map = new Gee.HashMap<string, Wingpanel.Indicator> ();
        indicators.@foreach ((entry) => {
            var val = entry.value;
            if (val.code_name == indicator.code_name) {
                deregister_map[entry.key] = val;
            }

            return true;
        });

        deregister_map.@foreach ((entry) => {
            deregister_indicator (entry.key, entry.value);
            return true;
        });

        indicators.@set (path, indicator);

        indicator_added (indicator);
    }

    /**
     * Deregisters an indicator.
     *
     * @param path The path to the plugin file. (Used to identify the indicator)
     * @param indicator The indicator.
     */
    public void deregister_indicator (string path, Wingpanel.Indicator indicator) {
        debug ("%s deregistered", indicator.code_name);

        if (!indicators.has_key (path)) {
            return;
        }

        if (indicators.unset (path)) {
            indicator_removed (indicator);
        }
    }

    /**
     * Checks if indicators are loaded.
     *
     * @return True if there are any indicators loaded.
     */
    public bool has_indicators () {
        return !indicators.is_empty;
    }

    /**
     * Gets the list of loaded indicators.
     *
     * @return a {@link Gee.Collection} containing the indicators.
     */
    public Gee.Collection<Wingpanel.Indicator> get_indicators () {
        return indicators.values.read_only_view;
    }
}

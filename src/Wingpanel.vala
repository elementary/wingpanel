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

namespace Wingpanel {
    public static int main (string[] args) {
        Gtk.init (ref args);
        var app = WingpanelApp.instance;

        return app.run (args);
    }

    public class WingpanelApp : Granite.Application {
        private static const OptionEntry[] OPTIONS = {
            { "open-indicator", 'o', 0, OptionArg.STRING, ref open_indicator, "Open an indicator", "code_name" },
            { "close-indicator", 'c', 0, OptionArg.STRING, ref close_indicator, "Close an indicator", "code_name" },
            { "toggle-indicator", 't', 0, OptionArg.STRING, ref toggle_indicator, "Toggle an indicator", "code_name" },
            { null }
        };

        private static string? open_indicator = null;
        private static string? close_indicator = null;
        private static string? toggle_indicator = null;

        private PanelWindow? panel_window = null;

        construct {
            application_id = "org.elementary.wingpanel";
            program_name = _("System Panel");
            app_years = "2015";
            exec_name = "wingpanel";
            app_launcher = exec_name + ".desktop";

            build_version = "2.0";
            app_icon = "wingpanel";
            main_url = "https://launchpad.net/wingpanel";
            bug_url = "https://bugs.launchpad.net/wingpanel";
            help_url = "https://answers.launchpad.net/wingpanel";
            translate_url = "https://translations.launchpad.net/wingpanel";
            about_authors = { "Wingpanel Developers", null };

            about_license_type = Gtk.License.GPL_3_0;
        }

        public static WingpanelApp _instance = null;

        public static WingpanelApp instance {
            get {
                if (_instance == null) {
                    _instance = new WingpanelApp ();
                }

                return _instance;
            }
        }

        public WingpanelApp () {
            IndicatorManager.get_default ().initialize (IndicatorManager.ServerType.SESSION);

            register_actions ();
        }

        public new int run (string[] args) {
            OptionContext context = new OptionContext ("");
            context.add_main_entries (OPTIONS, null);
            context.add_group (Gtk.get_option_group (false));

            try {
                context.parse (ref args);
            } catch {}

            if (process_actions ()) {
                return 0;
            }

            return base.run (args);
        }

        protected override void startup () {
            base.startup ();

            panel_window = new PanelWindow (this);
            panel_window.show_all ();
        }

        protected override void activate () {
            /* Do nothing */
        }

        private void register_actions () {
            SimpleAction list_indicators_action = new SimpleAction.stateful ("list-indicators", null, new Variant.strv (list_indicators ()));

            IndicatorManager indicator_manager = IndicatorManager.get_default ();
            indicator_manager.indicator_added.connect (() => {
                list_indicators_action.set_state (new Variant.strv (list_indicators ()));
            });
            indicator_manager.indicator_removed.connect (() => {
                list_indicators_action.set_state (new Variant.strv (list_indicators ()));
            });

            SimpleAction open_indicator_action = new SimpleAction ("open-indicator", VariantType.STRING);
            open_indicator_action.activate.connect ((parameter) => {
                if (panel_window == null) {
                    return;
                }

                panel_window.popover_manager.set_popover_visible (parameter.get_string (), true);
            });

            SimpleAction close_indicator_action = new SimpleAction ("close-indicator", VariantType.STRING);
            close_indicator_action.activate.connect ((parameter) => {
                if (panel_window == null) {
                    return;
                }

                panel_window.popover_manager.set_popover_visible (parameter.get_string (), false);
            });

            SimpleAction toggle_indicator_action = new SimpleAction ("toggle-indicator", VariantType.STRING);
            toggle_indicator_action.activate.connect ((parameter) => {
                if (panel_window == null) {
                    return;
                }

                panel_window.popover_manager.toggle_popover_visible (parameter.get_string ());
            });

            this.add_action (list_indicators_action);
            this.add_action (open_indicator_action);
            this.add_action (close_indicator_action);
            this.add_action (toggle_indicator_action);
        }

        private string[] list_indicators () {
            string[] code_names = {};

            foreach (Indicator indicator in IndicatorManager.get_default ().get_indicators ()) {
                code_names += indicator.code_name;
            }

            return code_names;
        }

        private bool process_actions () {
            try {
                register ();
            } catch (Error error) {
                warning ("Couldn't register application: %s", error.message);
            }

            if (open_indicator != null) {
                this.activate_action ("open-indicator", new Variant.string (open_indicator));

                return true;
            }

            if (close_indicator != null) {
                this.activate_action ("close-indicator", new Variant.string (close_indicator));

                return true;
            }

            if (toggle_indicator != null) {
                this.activate_action ("toggle-indicator", new Variant.string (toggle_indicator));

                return true;
            }

            return false;
        }
    }
}

#if TRANSLATION
_("A super sexy space-saving top panel");
#endif

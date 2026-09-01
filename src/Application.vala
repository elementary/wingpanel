/*
 * Copyright (c) 2011-2018 elementary, Inc. (https://elementary.io)
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

public class Wingpanel.Application : Gtk.Application {
    private const string SERVER_TYPE_ACTION_NAME = "greeter";
    private const string TOGGLE_INDICATOR_ACTION_NAME = "toggle-indicator";

    private const OptionEntry[] OPTIONS = {
        { SERVER_TYPE_ACTION_NAME, 'g', 0, OptionArg.NONE, null, "Server is a greeter", null },
        { TOGGLE_INDICATOR_ACTION_NAME, 't', 0, OptionArg.STRING, null, "Toggle an indicator", "code_name" },
        { null }
    };

    private PanelWindow panel_window;

    construct {
        flags = ApplicationFlags.HANDLES_COMMAND_LINE;
        application_id = "io.elementary.wingpanel";

        add_main_option_entries (OPTIONS);
    }

    protected override int command_line (ApplicationCommandLine command_line) {
        VariantDict options = command_line.get_options_dict ();

        if (options.contains (SERVER_TYPE_ACTION_NAME)) {
            IndicatorManager.get_default ().initialize (IndicatorManager.ServerType.GREETER);
        } else {
            IndicatorManager.get_default ().initialize (IndicatorManager.ServerType.SESSION);
        }

        if (options.contains (TOGGLE_INDICATOR_ACTION_NAME)) {
            activate_action (TOGGLE_INDICATOR_ACTION_NAME, options.lookup_value (TOGGLE_INDICATOR_ACTION_NAME, VariantType.STRING));
        }

        return 0;
    }

    protected override void startup () {
        base.startup ();

        Granite.init ();

        panel_window = new PanelWindow (this);
        panel_window.present ();

        var toggle_indicator_action = new SimpleAction (TOGGLE_INDICATOR_ACTION_NAME, VariantType.STRING);
        toggle_indicator_action.activate.connect ((parameter) => {
            panel_window.toggle_indicator (parameter.get_string ());
        });

        add_action (toggle_indicator_action);

        var keybinding_settings = new Settings ("io.elementary.panel.keybindings");
        var helper = KeybindingHelper.get_default ();

        var open_notifications_action = new KeybindingHelper.NamedAction (
            panel_window, "app." + TOGGLE_INDICATOR_ACTION_NAME, "messages"
        );

        helper.add_keybinding ("open-menu-notifications", keybinding_settings, open_notifications_action);
    }

    protected override void activate () {
        /* Do nothing */
    }

    public static int main (string[] args) {
        return new Wingpanel.Application ().run (args);
    }
}

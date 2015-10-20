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

namespace Wingpanel.Services {
    public class PanelSettings : Granite.Services.Settings {
        private static PanelSettings? instance = null;

        public bool use_transparency { get; set; }

        public PanelSettings () {
            base ("org.pantheon.desktop.wingpanel");
        }

        public static PanelSettings get_default () {
            if (instance == null) {
                instance = new PanelSettings ();
            }

            return instance;
        }
    }

    public class InterfaceSettings : Granite.Services.Settings {
        private static InterfaceSettings? instance = null;

        public string gtk_theme { get; set; }

        public InterfaceSettings () {
            base ("org.gnome.desktop.interface");
        }

        public static InterfaceSettings get_default () {
            if (instance == null) {
                instance = new InterfaceSettings ();
            }

            return instance;
        }
    }
}
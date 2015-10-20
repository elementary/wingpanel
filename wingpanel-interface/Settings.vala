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

public class WingpanelInterface.AnimationSettings : Granite.Services.Settings {
    public bool enable_animations { get; set; }
    public int open_duration { get; set; }
    public int snap_duration { get; set; }
    public int close_duration { get; set; }
    public int minimize_duration { get; set; }
    public int workspace_switch_duration { get; set; }
    public int menu_duration { get; set; }

    static AnimationSettings? instance = null;

    private AnimationSettings () {
        base ("org.pantheon.desktop.gala.animations");
    }

    public static unowned AnimationSettings get_default () {
        if (instance == null) {
            instance = new AnimationSettings ();
        }

        return instance;
    }
}
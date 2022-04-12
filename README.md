# Wingpanel
The extensible top panel for Pantheon. Wingpanel is an empty container that accepts indicators as extensions, including the applications menu. Individual indicators are hosted in their own repositories [here](https://github.com/search?q=topic%3Awingpanel+org%3Aelementary&type=Repositories).

[![Translation status](https://l10n.elementary.io/widgets/wingpanel/-/wingpanel/svg-badge.svg)](https://l10n.elementary.io/engage/wingpanel/?utm_source=widget)

## Building and Installation

You'll need the following dependencies:

* libgee-0.8-dev
* libglib2.0-dev
* libgranite-7-dev
* libgtk4-dev
* meson
* libmutter-2-dev
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install` then execute with `wingpanel`

    sudo ninja install
    wingpanel

## Preventing Wingpanel from restarting, e.g. for development

Wingpanel is started automatically on elementary OS with `gnome-session` autostarts. If you kill the `io.elementary.wingpanel` process twice within 60 seconds, it will keep `gnome-session` from restarting it until you log out or reboot.

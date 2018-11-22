# Wingpanel
The extensible top panel for Pantheon. Wingpanel is an empty container that accepts indicators as extensions, including the applications menu. Individual indicators are hosted in their own repositories [here](https://github.com/search?q=topic%3Awingpanel+org%3Aelementary&type=Repositories).

[![l10n](https://l10n.elementary.io/widgets/desktop/wingpanel/svg-badge.svg)](https://l10n.elementary.io/projects/wingpanel/)
[![Bountysource](https://www.bountysource.com/badge/tracker?tracker_id=43593927)](https://www.bountysource.com/teams/elementary/issues?tracker_ids=43593927)

## Building and Installation

You'll need the following dependencies:

* libgala-dev
* libgee-0.8-dev
* libglib2.0-dev
* libgranite-dev
* libgtk-3-dev
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

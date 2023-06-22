# Wingpanel
The extensible top panel for Pantheon. Wingpanel is an empty container that accepts indicators as extensions, including the applications menu. Individual indicators are hosted in their own repositories [here](https://github.com/search?q=topic%3Awingpanel+org%3Aelementary&type=Repositories).

[![Translation status](https://l10n.elementary.io/widgets/wingpanel/-/wingpanel/svg-badge.svg)](https://l10n.elementary.io/engage/wingpanel/?utm_source=widget)

## Building and Installation

You'll need the following dependencies:

* libgala-dev
* libgee-0.8-dev
* libglib2.0-dev
* libgranite-dev >= 5.4.0
* libgtk-3-dev
* libmutter-10-dev
* meson
* valac

You can install them using `./install_deps.sh`. (Also, this script is configuring the build environment and adds `build.sh` and `install.sh` scripts for better dev work):

    chmod +x ./install_deps.sh
    sudo ./install_deps.sh

After that, you can run `build.sh` to build:

    sudo ./build.sh

To install, use `install.sh` then execute with `io.elementary.wingpanel`:

    sudo ./install.sh
    io.elementary.wingpanel

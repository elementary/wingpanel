# Wingpanel
The extensible top panel for Pantheon. Wingpanel is an empty container that accepts indicators as extensions, including the applications menu. Individual indicators are hosted in their own repositories [here](https://github.com/search?q=topic%3Awingpanel+org%3Aelementary&type=Repositories).

[![l10n](https://l10n.elementary.io/widgets/desktop/wingpanel/svg-badge.svg)](https://l10n.elementary.io/projects/desktop/wingpanel)
[![Bountysource](https://www.bountysource.com/badge/tracker?tracker_id=43593927)](https://www.bountysource.com/teams/elementary/issues?tracker_ids=43593927)

## Building and Installation

It's recommended to create a clean build environment

    mkdir build
    cd build/
    
Run `cmake` to configure the build environment and then `make` to build

    cmake -DCMAKE_INSTALL_PREFIX=/usr ..
    make
    
To install, use `make install`, then execute with `wingpanel`

    sudo make install
    wingpanel

wingpanel_files = files(
    'PanelWindow.vala',
    'SessionManager.vala',
    'Application.vala',
    'Services/BackgroundManager.vala',
    'Services/IndicatorSorter.vala',
    'Services/PopoverManager.vala',
    'Widgets/IndicatorEntry.vala',
    'Widgets/IndicatorBar.vala',
    'Widgets/IndicatorPopover.vala',
    'Widgets/Panel.vala'
)

wingpanel_deps = [
    libwingpanel_dep,
    granite_dep,
    gdk_wl_dep,
    gdk_x11_dep,
    x11_dep,
    posix_dep,
    wl_client_dep,
    pantheon_desktop_shell_dep
]

executable(meson.project_name(),
    css_gresource,
    wingpanel_files,
    dependencies: wingpanel_deps,
    install: true
)

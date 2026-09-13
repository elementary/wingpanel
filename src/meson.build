wingpanel_files = files(
    'PanelWindow.vala',
    'Application.vala',
    'Services/BackgroundManager.vala',
    'Services/DisplayConfig.vala',
    'Services/PopoverManager.vala',
    'Services/WMDBus.vala',
    'Widgets/IndicatorEntry.vala',
    'Widgets/IndicatorBar.vala',
    'Widgets/Panel.vala'
)

wingpanel_deps = [
    libwingpanel_dep,
    granite_dep,
    gdk_wl_dep,
    posix_dep,
    wl_client_dep
]
if gtkls_dep.found()
    wingpanel_deps += [gtkls_dep]
endif
if gala_dep.found()
    wingpanel_deps += [pantheon_desktop_shell_dep]
endif

executable(meson.project_name(),
    css_gresource,
    wingpanel_files,
    dependencies: wingpanel_deps,
    install: true
)

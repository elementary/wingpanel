wingpanel_files = files(
    'Wingpanel.vala',
    'PanelWindow.vala',
    'Services/BackgroundManager.vala',
    'Services/IndicatorSorter.vala',
    'Services/PopoverManager.vala',
    'Services/Settings.vala',
    'Widgets/IndicatorEntry.vala',
    'Widgets/IndicatorMenuBar.vala',
    'Widgets/IndicatorPopover.vala',
    'Widgets/MenuBar.vala',
    'Widgets/Panel.vala',
    'Widgets/StyleClass.vala',
)

wingpanel_deps = [
    libwingpanel_dep,
    granite_dep,
]

executable(meson.project_name(),
    wingpanel_files,
    dependencies: wingpanel_deps,
    install: true
)

indicators_dir = join_paths(get_option('prefix'), get_option('libdir'), 'wingpanel')

config_vapi = meson.get_compiler('vala').find_library('config', dirs: meson.current_source_dir())

config_data = configuration_data()
config_data.set_quoted('INDICATORS_DIR', indicators_dir)

config_header = configure_file(
    configuration: config_data,
    output: 'config.h'
)

libwingpanel_deps = [
    glib_dep,
    gio_dep,
    gio_unix_dep,
    gmodule_dep,
    gee_dep,
    gtk_dep,
]

libwingpanel_lib = library('wingpanel',
    'Indicator.vala',
    'IndicatorManager.vala',
    'Widgets/Container.vala',
    'Widgets/OverlayIcon.vala',
    'Widgets/Separator.vala',
    'Widgets/Switch.vala',
    config_header,
    dependencies: [libwingpanel_deps, posix_dep, config_vapi],
    vala_header: 'wingpanel.h',
    version: meson.project_version(),
    install: true,
    install_dir: [true, join_paths(get_option('includedir'), 'wingpanel'), true]
)

pkg.generate(
    libwingpanel_lib,
    filebase: 'wingpanel',
    name: 'Wingpanel',
    description: 'Wingpanel Indicators API',
    version: meson.project_version(),
    subdirs: 'wingpanel',
    variables: ['indicatorsdir=${libdir}/wingpanel'],
    requires: libwingpanel_deps
)

install_data(
    'wingpanel.deps',
    install_dir: join_paths(get_option('datadir'), 'vala', 'vapi')
)

libwingpanel_dir = include_directories('.')
libwingpanel_dep = declare_dependency(
    link_with: libwingpanel_lib,
    dependencies: [libwingpanel_deps, config_vapi],
    include_directories: libwingpanel_dir
)

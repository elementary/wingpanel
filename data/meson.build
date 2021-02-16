install_data(
    'wingpanel.svg',
    rename: meson.project_name() + '.svg',
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', 'scalable', 'apps')
)

install_data(
    'autostart.desktop',
    rename: meson.project_name() + '.desktop',
    install_dir: join_paths(get_option('sysconfdir'), 'xdg', 'autostart')
)

i18n.merge_file(
    input: 'wingpanel.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'desktop',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'applications')
)

i18n.merge_file(
    input: 'wingpanel.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: join_paths(meson.source_root(), 'po', 'extra'),
    type: 'xml',
    install: true,
    install_dir: join_paths(get_option('datadir'), 'metainfo'),
)

# Use GResource
css_gresource = gnome.compile_resources(
    'gresource_css',
    'wingpanel.gresource.xml'
)

project(
    'wingpanel',
    'c', 'vala',
    version: '2.2.0',
)

lib_version = '0.2.0'

add_project_arguments([
        '--vapidir=' + join_paths(meson.source_root(), 'vapi'),
    ],
    language: 'vala',
)

add_project_arguments([
        '-DGETTEXT_PACKAGE="wingpanel"',
        '-DG_LOG_DOMAIN="wingpanel"'
    ],
    language: 'c'
)

indicators_dir = join_paths(get_option('prefix'), get_option('libdir'), 'wingpanel')

i18n = import('i18n')
pkg = import('pkgconfig')

glib_dep = dependency('glib-2.0', version: '>=2.32')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
gmodule_dep = dependency('gmodule-2.0')
gtk_dep = dependency('gtk+-3.0', version: '>=3.10')
gee_dep = dependency('gee-0.8')
granite_dep = dependency('granite')

subdir('data')
subdir('lib')
subdir('schemas')
subdir('src')
subdir('wingpanel-interface')
if get_option('example')
    subdir('sample')
endif
subdir('po')

meson.add_install_script('meson/post_install.py')

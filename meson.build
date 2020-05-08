project(
    'wingpanel',
    'c', 'vala',
    version: '2.3.1',
)

lib_version = '3.0.0'

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
gnome = import('gnome')
pkg = import('pkgconfig')

glib_dep = dependency('glib-2.0', version: '>=2.32')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
gmodule_dep = dependency('gmodule-2.0')
gtk_dep = dependency('gtk+-3.0', version: '>=3.10')
gee_dep = dependency('gee-0.8')
granite_dep = dependency('granite', version: '>=5.4.0')

subdir('data')
subdir('lib')
subdir('schemas')
subdir('src')
subdir('wingpanel-interface')
if get_option('example')
    subdir('sample')
endif
subdir('po')
vapigen = find_program('vapigen', required: false)
if vapigen.found()
	subdir('vapi')
endif

meson.add_install_script('meson/post_install.py')

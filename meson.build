project(
    'io.elementary.wingpanel',
    'c', 'vala',
    version: '8.0.0',
    meson_version : '>= 0.58.0'
)

add_project_arguments([
        '--vapidir=' + join_paths(meson.project_source_root(), 'vapi'),
    ],
    language: 'vala',
)

add_project_arguments([
        '-DGETTEXT_PACKAGE="wingpanel"',
        '-DG_LOG_DOMAIN="wingpanel"'
    ],
    language: 'c'
)

vala = meson.get_compiler('vala')

i18n = import('i18n')
gnome = import('gnome')
pkg = import('pkgconfig')

glib_dep = dependency('glib-2.0', version: '>=2.32')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
gmodule_dep = dependency('gmodule-2.0')
gdk_wl_dep = dependency('gtk4-wayland')
# GDK X11 dep is for detecting whether we're on Wayland or not ONLY, we don't actually have
# a hard X11 dependency here
gdk_x11_dep = dependency('gtk4-x11')
x11_dep = dependency('x11')
gtk_dep = dependency('gtk4')
gee_dep = dependency('gee-0.8')
granite_dep = dependency('granite-7')
posix_dep = meson.get_compiler('vala').find_library('posix')
wl_client_dep = dependency('wayland-client')

subdir('protocol')
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

gnome.post_install(glib_compile_schemas: true)

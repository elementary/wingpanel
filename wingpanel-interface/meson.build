mutter_dep = []
libmutter_dep = []

vala_flags = []
c_flags =['-DCLUTTER_ENABLE_COMPOSITOR_API', '-DCLUTTER_ENABLE_EXPERIMENTAL_API',
		'-DCOGL_ENABLE_EXPERIMENTAL_API', '-DCOGL_ENABLE_EXPERIMENTAL_2_0_API']

mutter40_dep = dependency('libmutter-8', version: ['>= 40', '< 41'], required: false)
if mutter40_dep.found()
	libmutter_dep = dependency('libmutter-8', version: '>= 40')
	mutter_dep = [
		dependency('mutter-cogl-8'), dependency('mutter-cogl-pango-8'),
		dependency('mutter-clutter-8')
	]
	vala_flags = []
endif

mutter41_dep = dependency('libmutter-9', version: ['>= 41', '< 42'], required: false)
if mutter41_dep.found()
	libmutter_dep = dependency('libmutter-9', version: '>= 41')
	mutter_dep = [
		libmutter_dep,
		dependency('mutter-cogl-9'), dependency('mutter-cogl-pango-9'),
		dependency('mutter-clutter-9')
	]
	vala_flags = ['--define', 'HAS_MUTTER41']
endif

mutter42_dep = dependency('libmutter-10', version: ['>= 42', '< 43'], required: false)
if mutter42_dep.found()
	libmutter_dep = dependency('libmutter-10', version: '>= 42')
	mutter_dep = [
		libmutter_dep,
		dependency('mutter-cogl-10'), dependency('mutter-cogl-pango-10'),
		dependency('mutter-clutter-10')
	]
	vala_flags = ['--define', 'HAS_MUTTER41', '--define', 'HAS_MUTTER42']
endif

mutter43_dep = dependency('libmutter-11', version: ['>= 43', '< 44'], required: false)
if mutter43_dep.found()
	libmutter_dep = dependency('libmutter-11', version: '>= 43')
	mutter_dep = [
		libmutter_dep,
		dependency('mutter-cogl-11'), dependency('mutter-cogl-pango-11'),
		dependency('mutter-clutter-11')
	]
	vala_flags = ['--define', 'HAS_MUTTER41', '--define', 'HAS_MUTTER42', '--define', 'HAS_MUTTER43']
endif

if mutter_dep.length() == 0
	error ('No supported mutter library found!')
endif

mutter_typelib_dir = libmutter_dep.get_pkgconfig_variable('typelibdir')

gala_dep = dependency('gala')
m_dep = meson.get_compiler('c').find_library('m', required: false)

shared_module(
    'wingpanel-interface',
    'Main.vala',
    'DBusServer.vala',
    'BackgroundManager.vala',
    'FocusManager.vala',
    'Utils.vala',
    dependencies: [gala_dep, granite_dep, mutter_dep, m_dep],
    vala_args: vala_flags,
    c_args: c_flags,
    install_rpath: mutter_typelib_dir,
    install: true,
    install_dir: join_paths(get_option('libdir'), 'gala', 'plugins'),
)


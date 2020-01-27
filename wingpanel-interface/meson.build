mutter_dep = []
libmutter_dep = []

vala_flags = ['--pkg', 'cogl-fixes']
c_flags = []

mutter328_dep = dependency('libmutter-2', version: ['>= 3.27', '< 3.29'], required: false)
if mutter328_dep.found()
    libmutter_dep = dependency('libmutter-2', version: '>= 3.27.92')
    mutter_dep = [
        dependency('mutter-cogl-2'), dependency('mutter-cogl-pango-2'),
        dependency('mutter-cogl-path-2'), dependency('mutter-clutter-2')
    ]
    vala_flags += []
    c_flags = ['-DCLUTTER_ENABLE_COMPOSITOR_API', '-DCLUTTER_ENABLE_EXPERIMENTAL_API',
        '-DCOGL_ENABLE_EXPERIMENTAL_API', '-DCOGL_ENABLE_EXPERIMENTAL_2_0_API']
endif

mutter330_dep = dependency('libmutter-3', version: ['>= 3.29.2', '< 3.31'], required: false)
if mutter330_dep.found()
    libmutter_dep = dependency('libmutter-3', version: '>= 3.29.2')
    mutter_dep = [
        dependency('mutter-cogl-3'), dependency('mutter-cogl-pango-3'),
        dependency('mutter-cogl-path-3'), dependency('mutter-clutter-3')
    ]
    vala_flags += ['--define', 'HAS_MUTTER330']
    c_flags = ['-DCLUTTER_ENABLE_COMPOSITOR_API', '-DCLUTTER_ENABLE_EXPERIMENTAL_API',
        '-DCOGL_ENABLE_EXPERIMENTAL_API', '-DCOGL_ENABLE_EXPERIMENTAL_2_0_API']
endif

mutter332_dep = dependency('libmutter-4', version: ['>= 3.31.2', '< 3.34'], required: false)
if mutter332_dep.found()
    libmutter_dep = dependency('libmutter-4', version: '>= 3.31.2')
    mutter_dep = [
        dependency('mutter-cogl-4'), dependency('mutter-cogl-pango-4'),
        dependency('mutter-cogl-path-4'), dependency('mutter-clutter-4')
    ]
    vala_flags += ['--define', 'HAS_MUTTER330', '--define', 'HAS_MUTTER332']
    c_flags = ['-DCLUTTER_ENABLE_COMPOSITOR_API', '-DCLUTTER_ENABLE_EXPERIMENTAL_API',
        '-DCOGL_ENABLE_EXPERIMENTAL_API', '-DCOGL_ENABLE_EXPERIMENTAL_2_0_API']
endif

mutter334_dep = dependency('libmutter-5', version: ['>= 3.34', '< 3.35.1'], required: false)
if mutter334_dep.found()
    libmutter_dep = dependency('libmutter-5', version: '>= 3.34')
    mutter_dep = [
        dependency('mutter-cogl-5'), dependency('mutter-cogl-pango-5'),
        dependency('mutter-cogl-path-5'), dependency('mutter-clutter-5')
    ]
    vala_flags += ['--define', 'HAS_MUTTER330', '--define', 'HAS_MUTTER332', '--define', 'HAS_MUTTER334']
    c_flags = ['-DCLUTTER_ENABLE_COMPOSITOR_API', '-DCLUTTER_ENABLE_EXPERIMENTAL_API',
        '-DCOGL_ENABLE_EXPERIMENTAL_API', '-DCOGL_ENABLE_EXPERIMENTAL_2_0_API']
endif

mutter336_dep = dependency('libmutter-6', version: ['>= 3.35.1', '< 3.38'], required: false)
if mutter336_dep.found()
    libmutter_dep = dependency('libmutter-6', version: '>= 3.35.1')
    mutter_dep = [
        dependency('mutter-cogl-6'), dependency('mutter-cogl-pango-6'),
        dependency('mutter-cogl-path-6'), dependency('mutter-clutter-6')
    ]
    vala_flags += ['--define', 'HAS_MUTTER330', '--define', 'HAS_MUTTER332', '--define', 'HAS_MUTTER334', '--define', 'HAS_MUTTER336']
    c_flags = ['-DCLUTTER_ENABLE_COMPOSITOR_API', '-DCLUTTER_ENABLE_EXPERIMENTAL_API',
        '-DCOGL_ENABLE_EXPERIMENTAL_API', '-DCOGL_ENABLE_EXPERIMENTAL_2_0_API']
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


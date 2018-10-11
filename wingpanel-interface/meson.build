mutter_dep = []
libmutter_dep = []

vala_flags = ['--pkg', 'cogl-fixes']
c_flags = []

mutter318_dep = dependency('libmutter', version: ['>= 3.18.3', '< 3.19'], required: false)
if mutter318_dep.found()
    libmutter_dep = dependency('libmutter')
    mutter_dep = [dependency('cogl-1.0'), dependency('clutter-1.0')]
endif

mutter320_dep = dependency('libmutter', version: ['>= 3.19', '< 3.21'], required: false)
if mutter320_dep.found()
    libmutter_dep = dependency('libmutter', version: '>= 3.20.3')
    mutter_dep = [dependency('cogl-1.0'), dependency('clutter-1.0')]
    vala_flags += ['--define', 'HAS_MUTTER320']
endif

mutter322_dep = dependency('libmutter', version: ['>= 3.21', '< 3.23'], required: false)
if mutter322_dep.found()
    libmutter_dep = dependency('libmutter', version: '>= 3.22.0')
    mutter_dep = [
        dependency('mutter-cogl-1.0'), dependency('mutter-cogl-pango-1.0'),
        dependency('mutter-cogl-path-1.0'), dependency('mutter-clutter-1.0')
    ]
    vala_flags += ['--define', 'HAS_MUTTER320', '--define', 'HAS_MUTTER322']
    c_flags = ['-DCLUTTER_ENABLE_COMPOSITOR_API', '-DCLUTTER_ENABLE_EXPERIMENTAL_API',
        '-DCOGL_ENABLE_EXPERIMENTAL_API', '-DCOGL_ENABLE_EXPERIMENTAL_2_0_API']
endif

mutter324_dep = dependency('libmutter-0', version: ['>= 3.23', '< 3.25'], required: false)
if mutter324_dep.found()
    libmutter_dep = dependency('libmutter-0', version: '>= 3.24.0')
    mutter_dep = [
        dependency('mutter-cogl-0'), dependency('mutter-cogl-pango-0'),
        dependency('mutter-cogl-path-0'), dependency('mutter-clutter-0')
    ]
    vala_flags += ['--define', 'HAS_MUTTER320', '--define', 'HAS_MUTTER322', '--define', 'HAS_MUTTER324']
    c_flags = ['-DCLUTTER_ENABLE_COMPOSITOR_API', '-DCLUTTER_ENABLE_EXPERIMENTAL_API',
        '-DCOGL_ENABLE_EXPERIMENTAL_API', '-DCOGL_ENABLE_EXPERIMENTAL_2_0_API']
endif

mutter326_dep = dependency('libmutter-1', version: ['>= 3.25', '< 3.27'], required: false)
if mutter326_dep.found()
    libmutter_dep = dependency('libmutter-1', version: '>= 3.26.0')
    mutter_dep = [
        dependency('mutter-cogl-1'), dependency('mutter-cogl-pango-1'),
        dependency('mutter-cogl-path-1'), dependency('mutter-clutter-1')
    ]
    vala_flags += ['--define', 'HAS_MUTTER320', '--define', 'HAS_MUTTER322', '--define', 'HAS_MUTTER324', '--define', 'HAS_MUTTER326']
    c_flags = ['-DCLUTTER_ENABLE_COMPOSITOR_API', '-DCLUTTER_ENABLE_EXPERIMENTAL_API',
        '-DCOGL_ENABLE_EXPERIMENTAL_API', '-DCOGL_ENABLE_EXPERIMENTAL_2_0_API']
endif

mutter328_dep = dependency('libmutter-2', version: ['>= 3.27', '< 3.29'], required: false)
if mutter328_dep.found()
    libmutter_dep = dependency('libmutter-2', version: '>= 3.27.92')
    mutter_dep = [
        dependency('mutter-cogl-2'), dependency('mutter-cogl-pango-2'),
        dependency('mutter-cogl-path-2'), dependency('mutter-clutter-2')
    ]
    vala_flags += ['--define', 'HAS_MUTTER320', '--define', 'HAS_MUTTER322', '--define', 'HAS_MUTTER324', '--define', 'HAS_MUTTER326', '--define', 'HAS_MUTTER328']
    c_flags = ['-DCLUTTER_ENABLE_COMPOSITOR_API', '-DCLUTTER_ENABLE_EXPERIMENTAL_API',
        '-DCOGL_ENABLE_EXPERIMENTAL_API', '-DCOGL_ENABLE_EXPERIMENTAL_2_0_API']
endif

mutter330_dep = dependency('libmutter-2', version: ['>= 3.29.2', '< 3.31'], required: false)
if mutter330_dep.found()
    libmutter_dep = dependency('libmutter-2', version: '>= 3.29.2')
    mutter_dep = [
        dependency('mutter-cogl-2'), dependency('mutter-cogl-pango-2'),
        dependency('mutter-cogl-path-2'), dependency('mutter-clutter-2')
    ]
    vala_flags += ['--define', 'HAS_MUTTER320', '--define', 'HAS_MUTTER322', '--define', 'HAS_MUTTER324', '--define', 'HAS_MUTTER326', '--define', 'HAS_MUTTER328', '--define', 'HAS_MUTTER330']
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
    'Settings.vala',
    'Utils.vala',
    dependencies: [gala_dep, granite_dep, mutter_dep, m_dep],
    vala_args: vala_flags,
    c_args: c_flags,
    install_rpath: mutter_typelib_dir,
    install: true,
    install_dir: join_paths(get_option('libdir'), 'gala', 'plugins'),
)


project('com.github.benpocalypse.circuitent', ['vala', 'c'],
    version: '0.0.1'
)

gnome = import('gnome')
i18n = import('i18n')

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

c_args = [
  '-include', 'config.h'
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : false)

executable(
    meson.project_name(),
    'src/circuitent.vala',
    'src/ieditor.vala',
    'src/schematic_editor.vala',
    'src/library_editor.vala',
    'src/library_entry.vala',
    'src/circuitent_drawing_surface.vala',
    'src/kicad_sch.vala',
    c_args: c_args,
    dependencies: [
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        m_dep
    ],
    install: true
)
subdir('data')

meson.add_install_script('meson/post_install.py')


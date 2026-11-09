project('overos-shell', version: '0.1.0', meson_version: '>=0.60.0')

shell_datadir = get_option('datadir') / 'overos-shell'

install_data(
  'app.js',
  'README.md',
  install_dir: shell_datadir,
)

install_data(
  '../overos-shell.css',
  '../astal.css',
  '../components.css',
  install_dir: shell_datadir,
)

install_data(
  'overos-shell.ini',
  install_dir: shell_datadir,
)

install_data(
  'overos-shell.desktop',
  install_dir: get_option('datadir') / 'applications',
)

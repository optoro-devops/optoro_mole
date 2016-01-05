name 'optoro_mole'
maintainer 'Optoro'
maintainer_email 'devops@optoro.com'
license 'MIT'
description 'This is a skeleton'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.3'

supports 'ubuntu', '= 14.04'

provides 'optoro_mole::default'

recipe 'optoro_mole::default', 'This is the default recipe for optoro_mole'

depends 'users'
depends 'sudo'

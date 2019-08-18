class Constant
  DOMAINS = {
    production: {
      sr: 'premesti-se.trk.in.rs',
      'sr-latin': 'sr-latin-premesti-se.trk.in.rs',
      en: 'en-premesti-se.trk.in.rs',
    },
    development: {
      sr: 'premesti-se-trk.in.localhost',
      'sr-latin': 'sr-latin-premesti-se.trk.in.localhost',
      en: 'en-premesti-se.trk.in.localhost',
    },
  }.freeze

  BLOG_PATH = '/blog/'.freeze

  COLORS = {
    a: '#b13ede',
    b: '#7cd7f7',
    c: '#fdcc00',
  }.freeze

  # 0..6
  AGE_COLORS = [
    COLORS[:a],
    COLORS[:b],
    COLORS[:c],
    '#e63232',
    '#4eab31',
    '#722ada',
    '#123099',
  ].freeze

  ARROW_CHAR = '↪'.freeze
end

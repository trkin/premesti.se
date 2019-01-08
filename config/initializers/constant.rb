class Constant
  DOMAINS = {
    production: {
      sr: 'www.premesti.se',
      'sr-latin': 'sr-latin.premesti.se',
      en: 'en.premesti.se',
    },
    development: {
      sr: 'sr.localhost',
      'sr-latin': 'sr-latin.localhost',
      en: 'en.localhost',
    },
    test: {
      sr: 'sr.localhost',
      'sr-latin': 'sr-latin.localhost',
      en: 'en.localhost',
    },
  }.freeze

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

class Constant
  DOMAINS = {
    production: {
      sr: 'www.premesti.se',
      'sr-latin': 'sr-latin.premesti.se',
      en: 'en.premesti.se',
    },
    development: {
      sr: 'sr.loc',
      'sr-latin': 'sr-latin.loc',
      en: 'en.loc',
    },
    test: {
      sr: 'sr.loc',
      'sr-latin': 'sr-latin.loc',
      en: 'en.loc',
    },
  }.freeze

  COLORS = {
    a: '#b13ede',
    b: '#7cd7f7',
    c: '#fdcc00',
  }.freeze

  # 1..7
  AGE_COLORS = [
    COLORS[:a],
    COLORS[:b],
    COLORS[:c],
    '#e63232',
    '#4eab31',
    '#722ada',
    '#123099',
  ].freeze
end

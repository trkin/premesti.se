class Constant
  DOMAINS = {
    production: {
      sr: "www.premesti.se",
      sr_latin: "sr-latin.premesti.se",
      en: "en.premesti.se",
    },
    development: {
      sr: "localhost",
      sr_latin: "sr-latin.localhost",
      en: "en.localhost",
    },
    test: {
      sr: "localhost",
      sr_latin: "sr-latin.localhost",
      en: "en.localhost",
    },
  }.freeze

  GROUP_NAMES = {
    two: 'Mladja jaslena grupa',
    three: 'Starija jaslena grupa',
    four: 'Mladja grupa',
    five: 'Srednja grupa',
    six: 'Starija grupa',
    seven: 'Predskolska grupa',
  }
end

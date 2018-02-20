class Constant
  DOMAINS = {
    production: {
      sr: "www.premesti.se",
      :'sr-latin' => "sr-latin.premesti.se",
      en: "en.premesti.se",
    },
    development: {
      sr: "localhost",
      :'sr-latin' => "sr-latin.localhost",
      en: "en.localhost",
    },
    test: {
      sr: "localhost",
      :'sr-latin' => "sr-latin.localhost",
      en: "en.localhost",
    },
  }.freeze
end

class Constant
  DOMAINS = {
    production: {
      sr: "www.premesti.se",
      :'sr-latin' => "sr-latin.premesti.se",
      en: "en.premesti.se",
    },
    development: {
      sr: "sr.loc",
      :'sr-latin' => "sr-latin.loc",
      en: "en.loc",
    },
    test: {
      sr: "sr.loc",
      :'sr-latin' => "sr-latin.loc",
      en: "en.loc",
    },
  }.freeze
end

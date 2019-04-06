# https://github.com/svenfuchs/i18n/blob/master/test/test_data/locales/plurals.rb
serbian = {
  i18n: {
    plural: {
      keys: %i[one few many other],
      rule: lambda { |n|
        if n % 10 == 1 && n % 100 != 11
          # 1, 21, 31 ...
          :one
        elsif [2, 3, 4].include?(n % 10) && ![12, 13, 14].include?(n % 100)
          # 2, 3, 4, 22, 23, 24, 32, 33, 34 ...
          :few
        # elsif (n % 10).zero? || [5, 6, 7, 8, 9].include?(n % 10) || [11, 12, 13, 14].include?(n % 100)
        #   :many
        # there are no other integers, use :many if you need to differentiate
        # with floats
        else
          # all other integers: 5, 6, ... 9, 10, 11, 12, 13, 14 ... 20, 25, ...
          :other
        end
      }
    }
  }
}
{
  sr: serbian,
  'sr-latin': serbian,
}

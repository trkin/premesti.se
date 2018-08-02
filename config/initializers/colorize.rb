class String
  COLOR = 31 # red

  def red
    "\e[#{COLOR}m#{self}\e[0m"
  end

  def colorize(string, return_result = false)
    last_index = 0
    res = ''
    while (new_index = self[last_index..-1].index(string))
      res += self[last_index..last_index + new_index - 1] if last_index + new_index - 1 > -1
      res += string.red
      last_index = last_index + new_index + string.length
    end
    res += self[last_index..-1]
    puts res
    res if return_result
  end
end

# require 'minitest/autorun'
# class Test < Minitest::Test
#   def test_one_substring
#     s = 'My name is Duke.'
#     assert_equal "My name is \e[31mDuke\e[0m.", s.colorize("Duke", true)
#   end
#
#   def test_two_substrings
#     s = 'Duke is my name, Duke.'
#     assert_equal "\e[31mDuke\e[0m is my name, \e[31mDuke\e[0m.", s.colorize("Duke", true)
#   end
#
#   def test_no_found
#     s = 'My name is Duke.'
#     assert_equal "My name is Duke.", s.colorize("Mike", true)
#   end
#
#   def test_whole
#     s = 'My name is Duke.'
#     assert_equal "\e[31mMy name is Duke.\e[0m", s.colorize(s, true)
#   end
#
#   def test_return
#     s = 'My name is Duke.'
#     assert_equal nil, s.colorize('Duke')
#   end
# end

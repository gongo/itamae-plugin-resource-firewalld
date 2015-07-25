require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'mocha/test_unit'
require 'itamae'

Itamae::Logger.log_device = StringIO.new

class BackendMock < ::Itamae::Backend::Local
  class UnexpectedCallError < StandardError ; end

  attr_reader :sent_file

  def run_command(*args)
    raise UnexpectedCallError.new('Should have been stubbing')
  end

  def send_file(src, dst)
    @sent_file = src
  end
end

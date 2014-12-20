require 'coveralls'
Coveralls.wear!

require 'test/unit'
require 'mocha/test_unit'
require 'itamae'

Itamae::Logger.log_device = StringIO.new

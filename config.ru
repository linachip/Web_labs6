require 'rack'
require_relative 'main'

use Rack::Logger
use Rack::Runtime
run App.new

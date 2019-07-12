# This file is used by Rack-based servers to start the application.
require './twackr'
require 'rack/protection'

#require ::File.expand_path('../config/environment',  __FILE__)
run Twackr

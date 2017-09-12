# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'
set :database, "postgres://localhost/[chatbot]"
run Rails.application



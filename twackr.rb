require 'rubygems'
require 'bundler'
require 'logger'

Bundler.require
require 'rack-flash'
require 'sinatra/contrib/all'

require 'i18n'
require 'i18n/backend/fallbacks'

$twackr_db_path = ENV.fetch('DATABASE_URL') rescue 'sqlite://db/development.sqlite3'
$twackr_db = Sequel.connect($twackr_db_path, :encoding => 'utf-8', :loggers => [Logger.new($stdout)])

Dir["#{File.dirname(__FILE__)}/app/helpers/*.rb"].each { |f| load(f) }
Dir["#{File.dirname(__FILE__)}/app/controllers/*.rb"].each { |f| load(f) }
Dir["#{File.dirname(__FILE__)}/app/models/*.rb"].each { |f| load(f) }

class Twackr < Sinatra::Base
	register Sinatra::Contrib
	register ApplicationController
	register ClientsController
	register EntriesController
	register ProjectsController
	register ServicesController
	register SessionsController
	register UsersController
	use Rack::Flash, :sweep => true
	use Rack::MethodOverride

	enable :sessions
	set :sessions, :expire_after => 2592000

	set :session_secret, (ENV.fetch('SESSION_SECRET') rescue "9359KDKSFKfjkekfgjke")

	set :views, Proc.new { File.join(root, "app", "views") }

	helpers ApplicationHelper, FormHelper, AuthenticatedSystem, ClientsHelper, EntriesHelper, PathHelper, ProjectsHelper, ServicesHelper, SessionsHelper, UsersHelper

	configure do
	  I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
	  I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
	  I18n.backend.load_translations

	  I18n.locale = 'en'
	end

end

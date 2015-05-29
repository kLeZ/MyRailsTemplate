# This is a template created to help me build standard apps that resemble my
# personal set of mandatory gems and app setup that I usually make by hand.


def source_paths
	Array(super) +
	[File.join(File.expand_path(File.dirname(__FILE__)), 'rails_root')]
end


def load_gems
	gsub_file "Gemfile", /^gem\s+["']sqlite3["'].*$/, ''

	# Mandatory Gems
	# ==========================================================================
	# This is the default encryption method used by devise 'https://github.com/codahale/bcrypt-ruby'
	gem 'bcrypt'

	# Bootstrap-Sass (https://github.com/twbs/bootstrap-sass)
	# ==========================================================================
	# Official Sass port of Bootstrap 'http://getbootstrap.com/css/#sass'
	gem 'bootstrap-sass'
	# It is also recommended to use Autoprefixer with Bootstrap to add browser vendor prefixes automatically. Simply add the gem:
	gem 'autoprefixer-rails'


	# Font-Awesome Sass gem for use in Ruby/Rails projects 'https://fortawesome.github.io/Font-Awesome/'
	gem 'font-awesome-sass'

	# Bootswatches converted to SCSS ready to use in Rails asset pipeline. 'https://github.com/maxim/bootswatch-rails'
	gem 'bootswatch-rails'

	# Formtastic form builder to generate Twitter Bootstrap-friendly markup. 'https://github.com/mjbellantoni/formtastic-bootstrap'
	gem 'formtastic-bootstrap'

	# Plug and play websocket support for ruby on rails. 'https://github.com/websocket-rails/websocket-rails'
	gem 'websocket-rails'

	# Flexible authentication solution for Rails with Warden. 'http://blog.plataformatec.com.br/tag/devise/'
	gem 'devise'
	gem 'devise_invitable'

	# Authorization Gem for Ruby on Rails. 'https://github.com/ryanb/cancan'
	gem 'cancan'
	gem 'rolify'

	# Forms made easy for Rails! It's tied to a simple DSL, with no opinion on markup. 'http://blog.plataformatec.com.br/tag/simple_form'
	gem 'simple_form'
end

def configure_environment
	environment "config.action_mailer.default_url_options = { host: 'localhost', port: '3000' }", env: 'development'
end

def generate_controllers
	# Generates a controller for the home page
	generate(:controller, 'home index')

	# Generates a controller for the about page, that IMHO is mandatory
	generate(:controller, 'about index')

	# Generates a controller for the contact page, that IMHO is mandatory
	generate(:controller, 'contact index')
end

def add_routes
	# Writes the default route to the home controller
	route "root to: 'home#index'"
	route "get 'contact' => 'contact#index'"
	route "get 'about' => 'about#index'"
	route "get 'index' => 'home#index'"
end

def run_initializers
	# Initialize Devise
	# ==========================================================================
	generate 'devise:install'
	generate 'devise_invitable:install'
	generate 'devise user'

	# Initialize CanCan
	# ==========================================================================
	generate 'cancan:ability'

	# Initialize Rolify
	# ==========================================================================
	generate 'rolify Role User'

	generate 'simple_form:install --bootstrap'
end

def configure_database
	# Configure database
	# ==========================================================================
	gsub_file "config/database.yml", /password:/, "password: MySQL@007"
	gsub_file "config/database.yml", /database: myapp_development/, "database: #{app_name}_development"
	gsub_file "config/database.yml", /database: myapp_test/,        "database: #{app_name}_test"
	gsub_file "config/database.yml", /database: myapp_production/,  "database: #{app_name}"
end

def configure_models
	# Adds a username field to the user model
	# in order to let the user enter a username and
	# be able to login either with a username or an email
	generate(:migration, 'AddUsernameToUsers', 'username:string')

	insert_into_file 'app/models/user.rb', :after => ':recoverable, :rememberable, :trackable, :validatable' do
		'attr_accessor :login

		def self.find_first_by_auth_conditions(warden_conditions)
			conditions = warden_conditions.dup
			if login = conditions.delete(:login)
				where(conditions).where(["username = :value OR lower(email) = lower(:value)", { :value => login }]).first
			else
				where(conditions).first
			end
		end'
	end

	insert_into_file 'app/config/initializers/devise.rb', :after => '# config.authentication_keys = [ :email ]' do
		'config.authentication_keys = [ :login ]'
	end

	insert_into_file 'app/config/initializers/devise.rb', :after => '# config.reset_password_keys = [ :email ]' do
		'config.reset_password_keys = [:login]'
	end

	insert_into_file 'config/locales/en.yml' do
"en:
  activerecord:
    attributes:
      user:
        login: \"Username or email\""
	end
end

def load_assets
	# Copy Assets
	# ==========================================================================
	remove_file 'app/assets/javascripts/application.js'
	remove_file 'app/assets/stylesheets/application.css'
	remove_file 'app/controllers/application_controller.rb'
	remove_file 'app/views/about/index.html.erb'
	remove_file 'app/views/contact/index.html.erb'
	remove_file 'app/views/home/index.html.erb'
	remove_file 'app/views/layouts/application.html.erb'
	remove_file 'config/initializers/assets.rb'

	inside 'app' do
		inside 'assets' do
			%w(
				home
				about
				contact
			).each do |controller|
				remove_file "javascripts/#{controller}.js.coffee"
				create_file "javascripts/#{controller}.js" do
					"// #{controller} Javascript file: it will be included only in views of its own controller"
				end

				remove_file "stylesheets/#{controller}.css.scss"
				create_file "stylesheets/#{controller}.css" do
					"/* #{controller} CSS file: it will be included only in views of its own controller */"
				end
			end

			inside 'javascripts' do
				create_file 'application.js', <<-CODE
//= require turbolinks
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require websocket_rails/main

!function($) {
	$(function() {
		var $root = $('html, body');

		$('a[data-spy="smooth"]').click(function() {
			var href = $.attr(this, 'href');
			$root.animate({
				scrollTop : $(href).offset().top + 2
			}, 500);
			return false;
		});
	})
}(window.jQuery);
				CODE

				copy_file 'additional-methods.js'
				copy_file 'additional-methods.min.js'
				copy_file 'bootstrap-datatable.js'
				copy_file 'bootstrap-datatable.min.js'
				copy_file 'html5shiv-printshiv.js'
				copy_file 'html5shiv.js'
				copy_file 'jquery.backstretch.min.js'
				copy_file 'jquery.booklet.latest.min.js'
				copy_file 'jquery.easing.1.3.js'
				copy_file 'jquery.loadTemplate.js'
				copy_file 'jquery.loadTemplate.min.js'
				copy_file 'jquery.metadata.js'
				copy_file 'jquery.tablecloth.js'
				copy_file 'jquery.tablesorter.js'
				copy_file 'jquery.validate.js'
				copy_file 'jquery.validate.min.js'
				copy_file 'respond.min.js'
			end
			inside 'stylesheets' do
				create_file 'application.css.scss', <<-CODE
/*
 *= require_self
 */
@CHARSET "UTF-8";

// Then bootstrap itself
// "bootstrap-sprockets" must be imported before "bootstrap" and "bootstrap/variables"
@import "bootstrap-sprockets";
@import "bootstrap";

@import "font-awesome-sprockets";
@import "font-awesome";
				CODE

				copy_file 'jquery.booklet.latest.css'
				copy_file 'prettify.css'
				copy_file 'structure.css'
			end
			inside 'images' do
				copy_file 'favicon.ico'
			end
		end
		inside 'controllers' do
			copy_file 'application_controller.rb'
		end
		inside 'views' do
			inside 'about' do
				copy_file 'index.html.erb'
			end
			inside 'contact' do
				copy_file 'index.html.erb'
			end
			inside 'home' do
				copy_file 'index.html.erb'
			end
			inside 'layouts' do
				create_file 'application.html.erb', <<-HTML
<!DOCTYPE html>
<html>
<head>
	<title>#{app_name} <%= yield :title %></title>
	<%= render 'layouts/html_head' %>
</head>
<body>
	<%= render 'layouts/navigation' %>
	<%= render 'layouts/alert_notice' %>
	<div class="container">
		<%= yield %>
	</div>
	<%= render 'layouts/back_to_top' %>
	<footer class="navbar navbar-bright navbar-fixed-bottom" role="navigation">
		<p style="padding: 10px;">&copy; D4nGuARd 2014</p>
	</footer>
</body>
</html>
				HTML

				copy_file '_alert_notice.html.erb'
				copy_file '_back_to_top.html.erb'
				copy_file '_profile_menu.html.erb'
				copy_file '_user_header.html.erb'
				template '_navigation.html.erb'
				copy_file '_navigation_links.html.erb'
				copy_file '_html_head.html.erb'
			end
		end
	end
	inside 'config' do
		inside 'initializers' do
			create_file 'assets.rb', <<-CODE
Rails.application.config.assets.precompile << Proc.new do |path|
	if path =~ /.(css|scss|js|coffee|ico|png|jpg|svg|ttf|woff|eot|cur)/
		full_path = Rails.application.assets.resolve(path).to_path
		app_assets_path = Rails.root.join('app', 'assets').to_path
		if full_path.starts_with? app_assets_path
			puts "including asset: " + full_path
			true
		else
			puts "excluding asset: " + full_path
			false
		end
	else
		puts "excluding path: " + path
		false
	end
end
			CODE
		end
	end

	application <<-CODE
		config.assets.initialize_on_precompile = true

		config.generators do |g|
			g.assets true
		end

		# Compress JavaScripts and CSS.
		config.assets.js_compressor = :uglifier
		config.assets.css_compressor = :sass
	CODE
end

generate_controllers

load_gems
load_assets

run 'bundle install'

configure_environment
configure_database

add_routes

run_initializers

rake 'db:drop'
rake 'db:create'

configure_models

rake 'db:migrate'

rake 'assets:clean'
rake 'assets:precompile'

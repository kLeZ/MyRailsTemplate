class ApplicationController < ActionController::Base
	before_filter :configure_permitted_parameters, if: :devise_controller?
	protect_from_forgery

	protected

	# Attempt to find a user by it's email. If a record is found, send new
	# password instructions to it. If not user is found, returns a new user
	# with an email not found error.
	def self.send_reset_password_instructions(attributes={})
		recoverable = find_recoverable_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
		recoverable.send_reset_password_instructions if recoverable.persisted?
		recoverable
	end

	def self.find_recoverable_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
		(case_insensitive_keys || []).each { |k| attributes[k].try(:downcase!) }

		attributes = attributes.slice(*required_attributes)
		attributes.delete_if { |key, value| value.blank? }

		if attributes.size == required_attributes.size
			if attributes.has_key?(:login)
				login = attributes.delete(:login)
				record = find_record(login)
			else
				record = where(attributes).first
			end
		end

		unless record
			record = new

			required_attributes.each do |key|
				value = attributes[key]
				record.send("#{key}=", value)
				record.errors.add(key, value.present? ? error : :blank)
			end
		end
		record
	end

	def self.find_record(login)
		where(["username = :value OR email = :value", { :value => login }]).first
	end

	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
		devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
		devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
	end
end

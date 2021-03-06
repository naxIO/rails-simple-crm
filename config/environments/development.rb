Mycrm::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load
  config.action_controller.action_on_unpermitted_parameters = :raise

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.assets.compress = false
  
#config.action_mailer.raise_delivery_errors = true
#config.action_mailer.delivery_method = :file
#config.action_mailer.file_settings = { :location => Rails.root.join('tmp/mail') }


config.default_mailaddress = 'yamashita.hayato@yourbright.co.jp'
config.action_mailer.default_url_options = { :host => "192.168.142.129", :port => 3000 }
#config.action_mailer.delivery_method = :letter_opener_web
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
end

end

#PDFKit.configure do |config|
#   config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf'
#end

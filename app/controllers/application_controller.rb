class ApplicationController < ActionController::Base
  include Authentication
  include SetCurrentVisitor
  include TrackEvent
  include Flash

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :track_event
end

module SetCurrentVisitor
  extend ActiveSupport::Concern

  included do
    before_action :set_current_visitor, if: :should_set_current_visitor?
  end

  private

  def set_current_visitor
    Current.visitor ||= Visitor.find_by(id: session[:visitor_id]) || create_current_visitor
  end

  def should_set_current_visitor?
    session[:enable_analytics] == true
  end

  def create_current_visitor
    visitor = Visitor.create!(
      user_agent: request.user_agent,
      user: current_user.presence
    )
    session[:visitor_id] = visitor.id

    visitor
  end
end

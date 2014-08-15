# Pundit must know which current user is

module PunditRailsAdminHelper
  extend ActiveSupport::Concern

  def pundit_user
    instance_eval(&RailsAdmin::Config.current_user_method)
  end
end

RailsAdmin::ApplicationController.send :include, PunditRailsAdminHelper

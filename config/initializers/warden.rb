require_relative "../../lib/session_helper"

Warden::Manager.after_authentication do |user, warden, opts|
  SessionHelper.create(user, warden)
end

Warden::Manager.after_set_user do |user, warden, opts|
  SessionHelper.validate_and_refresh(user, warden)
end

Warden::Manager.before_logout do |user, warden, opts|
  SessionHelper.logout(warden)
end

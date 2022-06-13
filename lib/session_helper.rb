module SessionHelper
  class ActiveSession < ActiveRecord::Base
    self.primary_key = "session_id"
  end

  # Time-to-live
  SESSION_TTL = 1.month

  # How often the TTL gets refreshed.
  # For performance reasons, we don't want to refresh TTL
  # on each request
  SESSION_TTL_REFRESH_INTERVAL = 1.day

  module_function

  def create(user, warden)
    cookie_session = warden.request.session
    sid = generate_sid

    ActiveSession.create(
      session_id: sid,
      person_id: user.id,
      community_id: user.community_id,
      ttl: Time.now)

    cookie_session[:db_sid] = sid
  end

  def validate_and_refresh(user, warden)
    cookie_session = warden.request.session
    db_session = ActiveSession.find_by(session_id: cookie_session[:db_sid])

    if db_session.nil?
      warden.logout
    elsif db_session.ttl < SESSION_TTL.ago
      warden.logout
    elsif db_session.ttl < SESSION_TTL_REFRESH_INTERVAL.ago
      db_session.touch(:ttl)
    end

    # temporary
    if db_session.present?
      populate_missing(user, db_session)
    end
  end

  def logout(warden)
    cookie_session = warden.request.session
    ActiveSession.delete_all(session_id: cookie_session[:db_sid])
  end

  # temporary

  def create_from_migrated()
    sid = generate_sid

    ActiveSession.create(
      session_id: sid,
      ttl: Time.now)
  end

  def populate_missing(user, db_session)
    if db_session.person_id.nil? || db_session.community_id.nil?
      db_session.update_attributes(person_id: user.id, community_id: user.community_id)
    end
  end

  # private

  def generate_sid
    SecureRandom.hex(16)
  end
end

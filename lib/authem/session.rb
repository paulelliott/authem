require "active_record"
require "authem/token"

module Authem
  class Session < ::ActiveRecord::Base
    self.table_name = :authem_sessions

    belongs_to :subject, polymorphic: true

    before_create do
      self.token ||= Authem::Token.generate
      self.ttl ||= 30.days
      self.expires_at ||= ttl_from_now
    end

    class << self
      def by_subject(record)
        where(subject_type: record.class.name, subject_id: record.id)
      end

      def active
        where(arel_table[:expires_at].gteq(Time.zone.now))
      end

      def expired
        where(arel_table[:expires_at].lt(Time.zone.now))
      end
    end

    def refresh
      self.expires_at = ttl_from_now
      save!
    end

    private

    def ttl_from_now
      ttl.to_i.from_now
    end
  end
end

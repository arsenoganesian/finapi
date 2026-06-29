module Transfers
  class LoadParticipantsService < ApplicationService
    def initialize(from_user_id:, recipient_email:)
      @from_user_id = from_user_id.to_i
      @recipient_email = recipient_email.to_s.strip.downcase
    end

    def call
      from_user = User.find_by(id: from_user_id)
      raise ActiveRecord::RecordNotFound, "Sender not found" unless from_user

      to_user = User.find_by(email: recipient_email)
      raise ActiveRecord::RecordNotFound, "Recipient not found" unless to_user

      { from_user:, to_user: }
    end

    private

    attr_reader :from_user_id, :recipient_email
  end
end

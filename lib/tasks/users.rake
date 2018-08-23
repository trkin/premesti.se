namespace :users do
  task resend_confirmation: :environment do
    users = User.all.where(confirmed_at: nil)
    users.each do |user|
      I18n.locale = user.locale.to_sym
      user.send_confirmation_instructions
    end
  end
end

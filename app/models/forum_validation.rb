require 'securerandom'

class ForumValidation < ActiveRecord::Base
  belongs_to :user
  belongs_to :author

  # Generate #vid
  before_save do
    self.vid = SecureRandom.hex(25) # 50
  end

  validates :user, presence: true
  validates :author, presence: true

  def associate_user_and_author!
    author.user = user
    author.save!
    update_column :validated, true
  end

  def send_pm
    if bot.authenticated? || authenticate_bot
      if user_forum_id = bot.get_user_id(author.forum_name)
        this_pm_sent = bot.send_pm(user_forum_id, I18n.t('forum_validations.pm.subject'), pm_message)
        self.pm_sent = pm_sent || this_pm_sent
        this_pm_sent
      else
        # User that we're trying to send a PM to wasn't found. This shouldn't
        # happen though, as there are no authors with invalid forum names
        false
      end
    else
      # Authentication is not working for some reason
      # We'll just do it old style and tell the user to shoot me a PM
      false
    end
  end

  private

  def authenticate_bot
    bot.authenticate(ENV['FORUM_BOT_ACCOUNT'], ENV['FORUM_BOT_PASSWORD'])
  end

  def pm_message
    part_1 = I18n.t 'forum_validations.pm.message',
      author_name: author.forum_name,
      email: user.email,
      url: Rails.application.routes.url_helpers.validate_forum_validation_url(self, vid: vid)

    mods_list = author.mods.where(owner: nil).map do |mod|
      url = Rails.application.routes.url_helpers.mod_url(mod)
      "- [url=#{url}]#{mod.name}[/url]"
    end.join('\n')

    part_2 = I18n.t 'forum_validations.pm.notice'

    part_1 + "\n" + mods_list + "\n" + part_2
  end

  def self.bot
    @bot ||= ForumBot.new
  end

  def bot
    self.class.bot
  end
end

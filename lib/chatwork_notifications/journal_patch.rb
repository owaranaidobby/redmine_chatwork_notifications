
module ChatworkNotifications
  module JournalPatch
    extend ActiveSupport::Concern

    included do
      unloadable
      after_create :notify_chatwork_after_create
    end

    private

    def notify_chatwork_after_create
      target_user_id = self.issue.assigned_to_id
      return unless Setting.plugin_redmine_chatwork_notifications[:issue_notify_on_update]
      return if Setting.plugin_redmine_chatwork_notifications[target_user_id.to_s].blank?
      return if self.private_notes? or self.issue.is_private?
      return if target_user_id == self.user_id

      notes = Helpers.truncate_words(self, :notes)
      url = Helpers.issue_url(self.issue)
      title = l("chatwork.issue_updated_notify_title", id: self.issue.id, url: url, title: self.issue.subject, user: self.user.name)
      description = l("chatwork.issue_updated_notify_description", comment: notes) if notes

      Helpers.put_chatwork_message target_user_id, [title, description.presence].compact.join("\n#{"-"*40}\n")
    end
  end
end


module ChatworkNotifications
  module IssuePatch
    extend ActiveSupport::Concern

    included do
      unloadable
      after_create :notify_chatwork_after_create
    end

    private

    def notify_chatwork_after_create
      return unless Setting.plugin_redmine_chatwork_notifications[:issue_notify_on_create]
      return if Setting.plugin_redmine_chatwork_notifications[self.assigned_to_id.to_s].blank?
      return if self.is_private?
      return if self.assigned_to_id.nil? or self.assigned_to_id == self.author_id

      description = Helpers.truncate_words self, :description
      url = Helpers.issue_url(self)
      title = l("chatwork.issue_created_notify_title", id: self.id, url: url, title: self.subject, user: self.author.name)
      description = l("chatwork.issue_created_notify_description", comment: description) if description

      Helpers.put_chatwork_message self.assigned_to_id, [title, description.presence].compact.join("\n#{"-"*40}\n")
    end
  end
end

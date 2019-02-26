module RedmineChangesetStatuses
  module Hooks
    class IncludeJavascriptHook < Redmine::Hook::ViewListener
      render_on :view_issues_show_details_bottom, :partial => "issues/changeset_statuses"
    end
  end
end

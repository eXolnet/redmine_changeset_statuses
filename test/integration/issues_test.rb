require File.expand_path('../../test_helper', __FILE__)

class IssuesTest < Redmine::IntegrationTest
  fixtures :projects,
           :users,
           :email_addresses,
           :roles,
           :members,
           :member_roles,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :issue_statuses,
           :issues,
           :enumerations,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers,
           :custom_fields_projects,
           :workflows,
           :journals,
           :journal_details,
           :repositories,
           :changesets

  def test_issue_show_should_include_changeset_statuses_assets
    get '/issues/1'

    assert_response :success
    assert_select 'script[src*="plugin_assets/redmine_changeset_statuses/changeset_statuses"]', 1
    assert_select 'head link[rel=stylesheet][href*="plugin_assets/redmine_changeset_statuses/changeset_statuses"]', 1
  end
end

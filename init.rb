require 'redmine'

CHANGESET_STATUSES_VERSION = '1.2.2'

Redmine::Plugin.register :redmine_changeset_statuses do
  name 'Changeset Statuses'
  author 'eXolnet'
  description 'Allows external services to set a state on revisions to consult it directly in Redmine.'
  version CHANGESET_STATUSES_VERSION
  url 'https://github.com/eXolnet/redmine_changeset_statuses'
  author_url 'https://www.exolnet.com'

  requires_redmine :version_or_higher => '3.4'
end

require File.dirname(__FILE__) + '/lib/redmine_changeset_statuses'

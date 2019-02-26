require 'redmine'

CHANGESET_STATUSES_VERSION_NUMBER = '0.0.1'

Redmine::Plugin.register :redmine_changeset_statuses do
  name 'Changeset Statuses'
  author 'eXolnet'
  description 'Allows external services to mark commits with an error, failure, pending, or success state.'
  version CHANGESET_STATUSES_VERSION_NUMBER
  url 'https://github.com/eXolnet/redmine_changeset_statuses'
  author_url 'https://www.exolnet.com'

  requires_redmine :version_or_higher => '3.4'
end

require 'redmine_changeset_statuses'

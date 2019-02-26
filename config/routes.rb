# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

post 'projects/:project_id/repository/statuses/:rev', :to => 'changeset_statuses#create'
post 'projects/:project_id/repository/:repository_id/statuses/:rev', :to => 'changeset_statuses#create'

get 'projects/:project_id/repository/statuses/:rev', :to => 'changeset_statuses#show'
get 'projects/:project_id/repository/:repository_id/statuses/:rev', :to => 'changeset_statuses#show'

get 'projects/:project_id/repository/revisions/:rev/status', :to => 'changeset_statuses#show_combined'
get 'projects/:project_id/repository/:repository_id/revisions/:rev/status', :to => 'changeset_statuses#show_combined'

class ChangesetStatusesController < ApplicationController
  accept_api_auth :create, :show

  before_action :require_api_request
  before_action :find_changeset

  def create
    render_403 unless User.current.allowed_to?(:commit_access, @project)

    @status = ChangesetStatus.new(
      :changeset   => @changeset,
      :author      => User.current,
      :state       => params[:state],
      :target_url  => params[:target_url],
      :description => params[:description],
      :context     => params[:state]
    )

    unless @status.save
      render_api_errors "#{l(:label_changeset_status)} #{l('activerecord.errors.messages.invalid')}"
      return
    end

    render_api_ok
  end

  def show
    render_403 unless User.current.allowed_to?(:view_changesets, @project)

    @offset, @limit = api_offset_and_limit
    @query = ChangesetStatus.changeset(@changeset)

    @status_count = @query.count
    @statuses = @query.order(:created_on => :desc).limit(@limit).offset(@offset).to_a

    render :template => 'changeset_statuses/show.api', :layout => nil
  end

  def show_combined
    render_403 unless User.current.allowed_to?(:view_changesets, @project)

    @offset, @limit = api_offset_and_limit
    @query = ChangesetStatus.changeset(@changeset).combined

    states_count = @query.group(:state).count
    @state = ChangesetStatus::STATES.find {|s| states_count.key?(s) }

    @status_count = @query.count
    @statuses = @query.order(:created_on => :desc).limit(@limit).offset(@offset).to_a

    render :template => 'changeset_statuses/show_combined.api', :layout => nil
  end

  private

  def require_api_request
    return true if api_request?
    deny_access
  end

  def find_changeset
    @project = Project.visible.find_by_param(params[:project_id])

    if params[:repository_id].present?
      @repository = @project.repositories.find_by_identifier_param(params[:repository_id])
    else
      @repository = @project.repository
    end

    (render_404; return false) unless @repository

    @changeset = @repository.find_changeset_by_name(params[:rev])
    (render_404; return false) unless @changeset
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end

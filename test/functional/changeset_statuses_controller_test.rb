require File.expand_path('../../test_helper', __FILE__)

class ChangesetStatusesControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :enabled_modules,
           :repositories,
           :changesets,
           :changeset_statuses

  def setup
    # Configure the logged user
    @request.session[:user_id] = 1
  end

  # API requests (json/xml) ignore the session, so authenticate with an API key
  def authenticate_with_api_key(user = User.find(1))
    Setting.rest_api_enabled = '1'
    @request.headers['X-Redmine-API-Key'] = user.api_key
  end

  def test_create_changeset_statuses_on_default_repository_with_minimal_parameters
    authenticate_with_api_key

    assert_difference 'ChangesetStatus.count' do
      compatible_request :post, :create, :project_id => 'ecookbook', :rev => '1', :format => 'json', :context => "continuous-integration/jenkins", :state => "success"

      assert_response 204
    end

    status = ChangesetStatus.order(:id).last
    assert_equal 100, status.changeset_id
    assert_equal 1, status.author_id
    assert_equal 'continuous-integration/jenkins', status.context
    assert_equal 'success', status.state
    assert_nil status.target_url
    assert_nil status.description
  end

  def test_create_changeset_statuses_on_default_repository_with_all_parameters
    authenticate_with_api_key

    assert_difference 'ChangesetStatus.count' do
      compatible_request :post, :create,
        :project_id => 'ecookbook',
        :rev => '1',
        :format => 'json',
        :state => "success",
        :target_url => "https://example.com/build/status",
        :description => "The build succeeded!",
        :context => "continuous-integration/jenkins"

      assert_response 204
    end

    status = ChangesetStatus.order(:id).last
    assert_equal 100, status.changeset_id
    assert_equal 'success', status.state
    assert_equal 'https://example.com/build/status', status.target_url
    assert_equal 'The build succeeded!', status.description
    assert_equal 'continuous-integration/jenkins', status.context
  end

  def test_create_changeset_statuses_with_commit_access_permission
    Role.find(1).add_permission! :commit_access
    authenticate_with_api_key User.find(2)

    assert_difference 'ChangesetStatus.count' do
      compatible_request :post, :create, :project_id => 'ecookbook', :rev => '2', :format => 'json', :context => "ci", :state => "pending"

      assert_response 204
    end

    status = ChangesetStatus.order(:id).last
    assert_equal 101, status.changeset_id
    assert_equal 2, status.author_id
  end

  def test_create_changeset_statuses_with_api_key_without_commit_access_permission
    authenticate_with_api_key User.find(2)

    assert_no_difference 'ChangesetStatus.count' do
      compatible_request :post, :create, :project_id => 'ecookbook', :rev => '2', :format => 'json', :context => "ci", :state => "pending"

      assert_response 403
    end
  end

  def test_create_changeset_statuses_with_invalid_parameters
    authenticate_with_api_key

    assert_no_difference 'ChangesetStatus.count' do
      compatible_request :post, :create, :project_id => 'ecookbook', :rev => '1', :format => 'json', :state => "unknown"

      assert_response 422
    end

    json = ActiveSupport::JSON.decode(response.body)
    assert_equal ['Changeset status is invalid'], json['errors']
  end

  def test_create_changeset_statuses_with_invalid_parameters_in_xml
    authenticate_with_api_key

    assert_no_difference 'ChangesetStatus.count' do
      compatible_request :post, :create, :project_id => 'ecookbook', :rev => '1', :format => 'xml', :context => 'ci'

      assert_response 422
    end

    assert_select 'errors error', :text => 'Changeset status is invalid'
  end

  def test_create_changeset_statuses_on_non_default_repository
    repository, changeset = create_non_default_repository_with_changeset
    authenticate_with_api_key

    assert_difference 'ChangesetStatus.count' do
      compatible_request :post, :create, :project_id => 'ecookbook', :repository_id => repository.identifier, :rev => '7', :format => 'json', :context => "ci", :state => "success"

      assert_response 204
    end

    assert_equal changeset.id, ChangesetStatus.order(:id).last.changeset_id
  end

  def test_create_changeset_statuses_without_commit_access
    assert_no_difference 'ChangesetStatus.count' do
      compatible_request :post, :create, :project_id => 'ecookbook', :rev => '1', :format => 'json', :context => "continuous-integration/jenkins", :state => "success"

      assert_response 403
    end
  end

  def test_create_changeset_statuses_on_default_repository_on_non_api_requests
    compatible_request :post, :create, :project_id => 'ecookbook', :rev => '1', :state => "success"

    assert_response 403
  end

  def test_create_changeset_statuses_on_invalid_project
    compatible_request :post, :create, :project_id => 'invalid', :rev => '1', :format => 'json', :state => "success"

    assert_response 404
  end

  def test_create_changeset_statuses_on_invalid_repository
    compatible_request :post, :create, :project_id => 'ecookbook', :repository_id => 'invalid', :format => 'json', :rev => '1', :state => "success"

    assert_response 404
  end

  def test_create_changeset_statuses_on_invalid_rev
    compatible_request :post, :create, :project_id => 'ecookbook', :rev => 'invalid', :format => 'json', :state => "success"

    assert_response 404
  end

  def test_show_changeset_statuses_on_default_repository
    compatible_request :get, :show, :project_id => 'ecookbook', :rev => '1', :format => 'json'

    assert_response :success

    json = ActiveSupport::JSON.decode(response.body)
    assert_equal 5, json['total_count']
    assert_equal 0, json['offset']
    assert_equal 25, json['limit']
    assert_equal [3, 2, 1, 4, 5], json['statuses'].map { |status| status['id'] }
    assert_equal(
      {
        'id' => 3,
        'state' => 'success',
        'target_url' => 'https://ci.example.com/builds/3',
        'description' => 'The build succeeded',
        'context' => 'continuous-integration/jenkins',
        'created_on' => '2024-01-01T12:00:00Z'
      },
      json['statuses'].first
    )
  end

  def test_show_changeset_statuses_with_offset_and_limit
    compatible_request :get, :show, :project_id => 'ecookbook', :rev => '1', :format => 'json', :offset => 1, :limit => 2

    assert_response :success

    json = ActiveSupport::JSON.decode(response.body)
    assert_equal 5, json['total_count']
    assert_equal 1, json['offset']
    assert_equal 2, json['limit']
    assert_equal [2, 1], json['statuses'].map { |status| status['id'] }
  end

  def test_show_changeset_statuses_in_xml
    compatible_request :get, :show, :project_id => 'ecookbook', :rev => '2', :format => 'xml'

    assert_response :success

    assert_select 'statuses[type=array][total_count="2"]' do
      assert_select 'status', 2
      assert_select 'status:first-child' do
        assert_select 'id', :text => '7'
        assert_select 'state', :text => 'success'
        assert_select 'context', :text => 'docs'
      end
    end
  end

  def test_show_changeset_statuses_without_statuses
    compatible_request :get, :show, :project_id => 'ecookbook', :rev => '10', :format => 'json'

    assert_response :success

    json = ActiveSupport::JSON.decode(response.body)
    assert_equal 0, json['total_count']
    assert_equal [], json['statuses']
  end

  def test_show_changeset_statuses_on_non_default_repository
    repository, changeset = create_non_default_repository_with_changeset
    status = ChangesetStatus.create!(:changeset => changeset, :author_id => 1, :context => 'ci', :state => 'success')

    compatible_request :get, :show, :project_id => 'ecookbook', :repository_id => repository.identifier, :rev => '7', :format => 'json'

    assert_response :success

    json = ActiveSupport::JSON.decode(response.body)
    assert_equal [status.id], json['statuses'].map { |s| s['id'] }
  end

  def test_show_changeset_statuses_without_view_changesets_permission
    Role.find(2).remove_permission! :view_changesets
    authenticate_with_api_key User.find(3)

    compatible_request :get, :show, :project_id => 'ecookbook', :rev => '1', :format => 'json'

    assert_response 403
  end

  def test_show_changeset_statuses_on_private_project_with_api_key
    changeset = Changeset.create!(:repository => Repository.find(11), :revision => '1', :committed_on => Time.now, :comments => 'Private')
    ChangesetStatus.create!(:changeset => changeset, :author_id => 1, :context => 'ci', :state => 'success')
    authenticate_with_api_key User.find(2)

    compatible_request :get, :show, :project_id => 'onlinestore', :rev => '1', :format => 'json'

    assert_response :success
    assert_equal 1, ActiveSupport::JSON.decode(response.body)['total_count']
  end

  def test_show_changeset_statuses_on_private_project_without_membership
    authenticate_with_api_key User.find(3)

    compatible_request :get, :show, :project_id => 'onlinestore', :rev => '1', :format => 'json'

    assert_response 404
  end

  def test_show_changeset_statuses_on_non_api_requests
    compatible_request :get, :show, :project_id => 'invalid', :rev => '1'

    assert_response 403
  end

  def test_show_changeset_statuses_on_invalid_project
    compatible_request :get, :show, :project_id => 'invalid', :rev => '1', :format => 'json'

    assert_response 404
  end

  def test_show_changeset_statuses_on_invalid_repository
    compatible_request :get, :show, :project_id => 'ecookbook', :repository_id => 'invalid', :rev => '1', :format => 'json'

    assert_response 404
  end

  def test_show_changeset_statuses_on_invalid_rev
    compatible_request :get, :show, :project_id => 'ecookbook', :rev => 'invalid', :format => 'json'

    assert_response 404
  end

  def test_show_combined_changeset_statuses_on_default_repository
    compatible_request :get, :show_combined, :project_id => 'ecookbook', :rev => '1', :format => 'json'

    assert_response :success

    json = ActiveSupport::JSON.decode(response.body)
    assert_equal 'error', json['state']
    assert_equal 3, json['total_count']
    assert_equal [3, 4, 5], json['statuses'].map { |status| status['id'] }
    assert_equal ['continuous-integration/jenkins', 'code-quality', 'docs'], json['statuses'].map { |status| status['context'] }
  end

  def test_show_combined_changeset_statuses_state_precedence
    {'2' => 'failure', '3' => 'pending', '4' => 'success'}.each do |rev, state|
      compatible_request :get, :show_combined, :project_id => 'ecookbook', :rev => rev, :format => 'json'

      assert_response :success
      assert_equal state, ActiveSupport::JSON.decode(response.body)['state'], "Wrong combined state for revision #{rev}"
    end
  end

  def test_show_combined_changeset_statuses_pending_should_take_precedence_over_error
    ChangesetStatus.create!(:changeset_id => 100, :author_id => 1, :context => 'deploy', :state => 'pending')

    compatible_request :get, :show_combined, :project_id => 'ecookbook', :rev => '1', :format => 'json'

    assert_response :success
    json = ActiveSupport::JSON.decode(response.body)
    assert_equal 'pending', json['state']
    assert_equal 4, json['total_count']
  end

  def test_show_combined_changeset_statuses_with_offset_and_limit
    compatible_request :get, :show_combined, :project_id => 'ecookbook', :rev => '1', :format => 'json', :offset => 1, :limit => 1

    assert_response :success

    json = ActiveSupport::JSON.decode(response.body)
    assert_equal 'error', json['state']
    assert_equal 3, json['total_count']
    assert_equal 1, json['offset']
    assert_equal 1, json['limit']
    assert_equal [4], json['statuses'].map { |status| status['id'] }
  end

  def test_show_combined_changeset_statuses_in_xml
    compatible_request :get, :show_combined, :project_id => 'ecookbook', :rev => '2', :format => 'xml'

    assert_response :success

    assert_select 'statuses[type=array][state="failure"][total_count="2"]' do
      assert_select 'status', 2
    end
  end

  def test_show_combined_changeset_statuses_without_statuses
    compatible_request :get, :show_combined, :project_id => 'ecookbook', :rev => '10', :format => 'json'

    assert_response :success

    json = ActiveSupport::JSON.decode(response.body)
    assert_nil json['state']
    assert_equal 0, json['total_count']
    assert_equal [], json['statuses']
  end

  def test_show_combined_changeset_statuses_on_non_default_repository
    repository, changeset = create_non_default_repository_with_changeset
    ChangesetStatus.create!(:changeset => changeset, :author_id => 1, :context => 'ci', :state => 'failure')

    compatible_request :get, :show_combined, :project_id => 'ecookbook', :repository_id => repository.identifier, :rev => '7', :format => 'json'

    assert_response :success
    assert_equal 'failure', ActiveSupport::JSON.decode(response.body)['state']
  end

  def test_show_combined_changeset_statuses_without_view_changesets_permission
    Role.find(5).remove_permission! :view_changesets

    compatible_request :get, :show_combined, :project_id => 'ecookbook', :rev => '1', :format => 'json'

    assert_response 403
  end

  def test_show_combined_changeset_statuses_on_private_project_with_api_key
    changeset = Changeset.create!(:repository => Repository.find(11), :revision => '1', :committed_on => Time.now, :comments => 'Private')
    ChangesetStatus.create!(:changeset => changeset, :author_id => 1, :context => 'ci', :state => 'failure')
    authenticate_with_api_key User.find(2)

    compatible_request :get, :show_combined, :project_id => 'onlinestore', :rev => '1', :format => 'json'

    assert_response :success
    assert_equal 'failure', ActiveSupport::JSON.decode(response.body)['state']
  end

  def test_show_combined_changeset_statuses_with_xhr_should_use_session
    changeset = Changeset.create!(:repository => Repository.find(11), :revision => '1', :committed_on => Time.now, :comments => 'Private')
    ChangesetStatus.create!(:changeset => changeset, :author_id => 1, :context => 'ci', :state => 'success')
    @request.session[:user_id] = 2

    compatible_xhr_request :get, :show_combined, :project_id => 'onlinestore', :rev => '1', :format => 'json'

    assert_response :success
    assert_equal 'success', ActiveSupport::JSON.decode(response.body)['state']
  end

  def test_show_combined_changeset_statuses_without_xhr_should_ignore_session
    @request.session[:user_id] = 2

    compatible_request :get, :show_combined, :project_id => 'onlinestore', :rev => '1', :format => 'json'

    assert_response 404
  end

  def test_show_combined_changeset_statuses_on_non_api_requests
    compatible_request :get, :show_combined, :project_id => 'invalid', :rev => '1'

    assert_response 403
  end

  def test_show_combined_changeset_statuses_on_invalid_project
    compatible_request :get, :show_combined, :project_id => 'invalid', :rev => '1', :format => 'json'

    assert_response 404
  end

  def test_show_combined_changeset_statuses_on_invalid_repository
    compatible_request :get, :show_combined, :project_id => 'ecookbook', :repository_id => 'invalid', :rev => '1', :format => 'json'

    assert_response 404
  end

  def test_show_combined_changeset_statuses_on_invalid_rev
    compatible_request :get, :show_combined, :project_id => 'ecookbook', :rev => 'invalid', :format => 'json'

    assert_response 404
  end

  private

  def create_non_default_repository_with_changeset
    repository = Repository::Subversion.create!(
      :project => Project.find(1),
      :identifier => 'other',
      :url => 'file:///tmp/other_repository',
      :is_default => false
    )
    changeset = Changeset.create!(:repository => repository, :revision => '7', :committed_on => Time.now, :comments => 'Other')

    [repository, changeset]
  end
end

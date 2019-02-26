require File.expand_path('../../test_helper', __FILE__)

class ChangesetStatusesControllerTest < ActionController::TestCase
  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :enabled_modules,
           :repositories,
           :changesets

  def setup
    # Configure the logged user
    @request.session[:user_id] = 1
  end

  def test_create_changeset_statuses_on_default_repository_with_minimal_parameters
    assert_difference 'ChangesetStatus.count' do
      post :create, :project_id => 'ecookbook', :rev => '1', :format => 'json', :state => "success"

      assert_response :success
    end

    status = ChangesetStatus.last
    assert_kind_of ChangesetStatus, status
  end

  def test_create_changeset_statuses_on_default_repository_with_all_parameters
    assert_difference 'ChangesetStatus.count' do
      post :create,
        :project_id => 'ecookbook',
        :rev => '1',
        :format => 'json',
        :state => "success",
        :target_url => "https://example.com/build/status",
        :description => "The build succeeded!",
        :context => "continuous-integration/jenkins"

      assert_response :success
    end

    status = ChangesetStatus.last
    assert_kind_of ChangesetStatus, status
  end

  def test_create_changeset_statuses_on_default_repository_on_non_api_requests
    post :create, :project_id => 'ecookbook', :rev => '1', :state => "success"

    assert_response 403
  end

  def test_create_changeset_statuses_on_invalid_project
    post :create, :project_id => 'invalid', :rev => '1', :format => 'json', :state => "success"

    assert_response 404
  end

  def test_create_changeset_statuses_on_invalid_repository
    post :create, :project_id => 'ecookbook', :repository_id => 'invalid', :format => 'json', :rev => '1', :state => "success"

    assert_response 404
  end

  def test_create_changeset_statuses_on_invalid_rev
    post :create, :project_id => 'ecookbook', :rev => 'invalid', :format => 'json', :state => "success"

    assert_response 404
  end

  def test_show_changeset_statuses_on_default_repository
    get :show, :project_id => 'ecookbook', :rev => '1', :format => 'json'

    assert_response :success
  end

  def test_show_changeset_statuses_on_non_api_requests
    get :show, :project_id => 'invalid', :rev => '1'

    assert_response 403
  end

  def test_show_changeset_statuses_on_invalid_project
    get :show, :project_id => 'invalid', :rev => '1', :format => 'json'

    assert_response 404
  end

  def test_show_changeset_statuses_on_invalid_repository
    get :show, :project_id => 'ecookbook', :repository_id => 'invalid', :rev => '1', :format => 'json'

    assert_response 404
  end

  def test_show_changeset_statuses_on_invalid_rev
    get :show, :project_id => 'ecookbook', :rev => 'invalid', :format => 'json'

    assert_response 404
  end

  def test_show_combined_changeset_statuses_on_default_repository
    get :show_combined, :project_id => 'ecookbook', :rev => '1', :format => 'json'

    assert_response :success
  end

  def test_show_combined_changeset_statuses_on_non_api_requests
    get :show_combined, :project_id => 'invalid', :rev => '1'

    assert_response 403
  end

  def test_show_combined_changeset_statuses_on_invalid_project
    get :show_combined, :project_id => 'invalid', :rev => '1', :format => 'json'

    assert_response 404
  end

  def test_show_combined_changeset_statuses_on_invalid_repository
    get :show_combined, :project_id => 'ecookbook', :repository_id => 'invalid', :rev => '1', :format => 'json'

    assert_response 404
  end

  def test_show_combined_changeset_statuses_on_invalid_rev
    get :show_combined, :project_id => 'ecookbook', :rev => 'invalid', :format => 'json'

    assert_response 404
  end
end

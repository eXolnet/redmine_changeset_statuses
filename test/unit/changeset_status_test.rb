require File.expand_path('../../test_helper', __FILE__)

class ChangesetStatusTest < ActiveSupport::TestCase
  fixtures :projects,
           :users,
           :repositories,
           :changesets,
           :changeset_statuses

  def test_create
    status = ChangesetStatus.new(
      :changeset => Changeset.find(100),
      :author => User.find(2),
      :context => 'continuous-integration/jenkins',
      :state => 'success'
    )

    assert status.save
    status.reload
    assert_equal 100, status.changeset_id
    assert_equal 2, status.author_id
    assert_not_nil status.created_on
  end

  def test_should_require_state_changeset_context_and_author
    status = ChangesetStatus.new

    assert_not status.valid?
    [:state, :changeset_id, :context, :author_id].each do |attribute|
      assert_include attribute, status.errors.attribute_names
    end
  end

  def test_state_should_be_included_in_states
    status = valid_status

    ChangesetStatus::STATES.each do |state|
      status.state = state
      assert status.valid?, "#{state} should be valid"
    end

    status.state = 'unknown'
    assert_not status.valid?
    assert_include :state, status.errors.attribute_names
  end

  def test_length_limits
    [:target_url, :description, :context].each do |attribute|
      status = valid_status

      status.send("#{attribute}=", 'a' * 255)
      assert status.valid?, "#{attribute} of 255 characters should be valid"

      status.send("#{attribute}=", 'a' * 256)
      assert_not status.valid?, "#{attribute} of 256 characters should be invalid"
      assert_include attribute, status.errors.attribute_names
    end
  end

  def test_target_url_and_description_are_optional
    status = valid_status
    status.target_url = nil
    status.description = nil

    assert status.valid?
  end

  def test_changeset_scope_with_changeset_object
    assert_equal [1, 2, 3, 4, 5], ChangesetStatus.changeset(Changeset.find(100)).order(:id).pluck(:id)
  end

  def test_changeset_scope_with_id
    assert_equal [6, 7], ChangesetStatus.changeset(101).order(:id).pluck(:id)
  end

  def test_changeset_scope_with_mixed_array
    assert_equal [6, 7, 8, 9], ChangesetStatus.changeset([Changeset.find(101), 102, nil]).order(:id).pluck(:id)
  end

  def test_changeset_scope_without_changeset_should_return_none
    assert_equal [], ChangesetStatus.changeset(nil).to_a
    assert_equal [], ChangesetStatus.changeset([]).to_a
  end

  def test_combined_scope_should_keep_latest_status_per_context
    assert_equal [3, 4, 5], ChangesetStatus.changeset(100).combined.order(:id).pluck(:id)
    assert_equal [6, 7], ChangesetStatus.changeset(101).combined.order(:id).pluck(:id)
  end

  def test_combined_scope_should_not_mix_changesets
    assert_equal [3, 4, 5, 6, 7], ChangesetStatus.changeset([100, 101]).combined.order(:id).pluck(:id)
  end

  def test_repository_and_project
    status = ChangesetStatus.find(1)

    assert_equal Repository.find(10), status.repository
    assert_equal Project.find(1), status.project
  end

  def test_changeset_id_setter_should_reset_changeset_association
    status = ChangesetStatus.find(1)
    assert_equal Changeset.find(100), status.changeset

    status.changeset_id = 101

    assert_equal 101, status.changeset_id
    assert_equal Changeset.find(101), status.changeset
  end

  def test_author_id_setter_should_reset_author_association
    status = ChangesetStatus.find(1)
    assert_equal User.find(1), status.author

    status.author_id = 2

    assert_equal 2, status.author_id
    assert_equal User.find(2), status.author
  end

  private

  def valid_status
    ChangesetStatus.new(
      :changeset_id => 100,
      :author_id => 1,
      :context => 'continuous-integration/jenkins',
      :state => 'success'
    )
  end
end

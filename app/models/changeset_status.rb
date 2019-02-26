class ChangesetStatus < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :changeset

  validates_presence_of :state, :changeset_id
  validates_inclusion_of :state, :in => %w{pending success failure error}
  validates_length_of :target_url, :maximum => 255, :allow_nil => true
  validates_length_of :description, :maximum => 255, :allow_nil => true
  validates_length_of :context, :maximum => 255, :allow_nil => true

  attr_protected :id

  def repository
    changeset.repository
  end

  def project
    changeset.project
  end

  def changeset_id=(cid)
    self.changeset = nil
    write_attribute(:changeset_id, cid)
  end
end

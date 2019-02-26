class ChangesetStatus < ActiveRecord::Base
  include Redmine::SafeAttributes

  STATES = %w{pending error failure success}

  belongs_to :changeset
  belongs_to :author, :class_name => 'User'

  validates_presence_of :state, :changeset_id, :author_id
  validates_inclusion_of :state, :in => STATES
  validates_length_of :target_url, :maximum => 255, :allow_nil => true
  validates_length_of :description, :maximum => 255, :allow_nil => true
  validates_length_of :context, :maximum => 255, :allow_nil => true

  attr_protected :id

  scope :changeset, lambda {|changesets|
    ids = [changesets].flatten.compact.map {|c| c.is_a?(Changeset) ? c.id : c}
    ids.any? ? where(:changeset_id => ids) : none
  }

  scope :combined, lambda {
    where("NOT EXISTS (SELECT 1 FROM #{table_name} csc WHERE csc.changeset_id = #{table_name}.changeset_id "+
      "AND csc.context IS NOT NULL "+
      "AND csc.context = #{table_name}.context "+
      "AND csc.created_on > #{table_name}.created_on)")
  }

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

  def author_id=(cid)
    self.author = nil
    write_attribute(:author_id, cid)
  end
end

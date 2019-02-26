migration_class = ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration

class CreateChangesetStatuses < migration_class
  def change
    create_table :changeset_statuses do |t|
      t.integer  :changeset_id,          :null => false
      t.string   :state,                 :null => false
      t.string   :target_url
      t.string   :description
      t.string   :context
      t.integer  :author_id,             :null => false
      t.datetime :created_on,            :null => false
      t.datetime :updated_on,            :null => false
    end

    add_index "changeset_statuses", ["changeset_id", "context", "created_on"], :name => "changeset_statuses_changeset_id_context_created_on"
  end
end

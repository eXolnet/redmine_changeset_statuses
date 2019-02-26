migration_class = ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[4.2] : ActiveRecord::Migration

class CreateChangesetStatuses < migration_class
  def change
    create_table :changeset_statuses do |t|
      t.integer  :changeset_id,          :null => false
      t.string   :state,                 :null => false
      t.string   :target_url
      t.string   :description
      t.string   :context
      t.datetime :created_on,            :null => false
    end
  end
end

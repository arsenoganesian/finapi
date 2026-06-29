class AddExternalIdToUsers < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    add_column :users, :external_id, :uuid, default: "gen_random_uuid()", null: false
    add_index :users, :external_id, unique: true
  end
end

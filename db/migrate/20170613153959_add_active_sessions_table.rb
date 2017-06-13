class AddActiveSessionsTable < ActiveRecord::Migration
  def up
    create_table :active_sessions, id: false do |t|
      t.string :session_id, null: false, limit: 32 # SecureRandom.hex(16).length == 32

      # person_id and community_id can be set null: false after
      # the migration period from database store to cookie store
      # is over
      t.string :person_id, limit: 22
      t.integer :community_id

      t.datetime :ttl, null: false

      t.timestamps null: false
    end

    add_index :active_sessions, :person_id
    add_index :active_sessions, :community_id
    add_index :active_sessions, :ttl

    execute "ALTER TABLE active_sessions ADD PRIMARY KEY (session_id)"
  end

  def down
    drop_table :active_sessions
  end
end

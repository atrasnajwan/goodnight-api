class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.index [ "name" ], name: "index_users_on_name"

      t.timestamps
    end
  end
end

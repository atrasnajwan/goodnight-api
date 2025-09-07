class CreateFollowings < ActiveRecord::Migration[8.0]
  def change
    create_table :followings do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :followed, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    # index to make sure no duplicate follower/following user
    add_index :followings, [ :followed_id, :follower_id ], unique: true
    # followers index
    add_index :followings, [ :follower_id, :created_at ] # for sort by latest/earliest
    # followings index
    add_index :followings, [ :followed_id, :created_at ] # for sort by latest/earliest
  end
end

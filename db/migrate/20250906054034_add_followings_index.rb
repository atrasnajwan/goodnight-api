class AddFollowingsIndex < ActiveRecord::Migration[8.0]
  def change
    # followers index
    add_index :followings, [ :follower_id, :created_at ] # for sort by latest/earliest
    # followings index
    add_index :followings, [ :followed_id, :created_at ] # for sort by latest/earliest
  end
end

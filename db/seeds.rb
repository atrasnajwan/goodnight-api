# Create initial users
users = [
    { name: "Alice Cooper" },
    { name: "Bryan Garris" },
    { name: "Chad Smith" },
    { name: "Dave Mustain" }
]
# create users
users.each do |user|
    User.create!(user)
end

alice = User.find_by(name: "Alice Cooper")
bryan = User.find_by(name: "Bryan Garris")
chad = User.find_by(name: "Chad Smith")
dave = User.find_by(name: "Dave Mustain")

pairs = [
    # follower, followed
    [ alice, bryan ],
    [ alice, chad ],
    [ bryan, alice ],
    [ bryan, dave ],
    [ chad, alice ]
]

pairs.each do |follower, followed|
    Following.create!(follower: follower, followed: followed)
end

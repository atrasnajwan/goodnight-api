# Good Night Api

This app allows users to track when they go to sleep and when they wake up. Users can follow other user to see their sleep schedules.

## Database
>Note:
Make sure your PostgresSQL service is running and change the environment variable on config/application.yml

### **Users**
| Column      | Type     | Description           |
|-------------|----------|-----------------------|
| id          | integer  | Primary key           |
| name        | string   | Required              |
| created_at  | datetime | Record creation time  |
| updated_at  | datetime | Last update time      |

**Indexes**:
- `index_users_on_name`

---

### **SleepRecords**
Tracks when a user clocks in and out for sleep.

| Column         | Type     | Description                              |
|----------------|----------|------------------------------------------|
| id             | integer  | Primary key                              |
| user_id        | integer  | Foreign key to `users`                   |
| clocked_in_at  | datetime | Time user went to sleep (Default: CURRENT_TIMESTAMP)       |
| clocked_out_at | datetime | Time user woke up (Nullable until clocked out) |
| duration_hours | decimal(10, 2) | Duration of sleep in hours |
| created_at     | datetime | Record creation time                     |
| updated_at     | datetime | Last update time                         |

**Indexes**:
- `index_sleep_records_on_clocked_in_at` -> for sorting by `clocked_in_at`
- `index_sleep_records_on_clocked_out_at` -> for sorting by `clocked_out_at`
- `index_sleep_records_on_duration_hours` -> for sorting by `duration_hours` (only applied when `clocked_out_at` is not null)
- `index_sleep_records_on_user_id_and_clocked_in_at` -> for sorting by `clocked_in_at` when showing sleep records for a specific user
- `index_sleep_records_on_user_id_and_clocked_out_at` -> for sorting by `clocked_out_at` when showing sleep records for a specific user
- `index_sleep_records_on_user_id_and_duration_hours` -> for sorting by `duration_hours` when showing sleep records for a specific user (only applied when `clocked_out_at` is not null)

**Foreign Keys**:
- `user_id` -> `users.id`

---

### **Followings**
Represents a follower-followed relationship between users.

| Column       | Type     | Description                    |
|--------------|----------|--------------------------------|
| id           | integer  | Primary key                    |
| follower_id  | integer  | User who follows               |
| followed_id  | integer  | User being followed            |
| created_at   | datetime | Record creation time           |
| updated_at   | datetime | Last update time               |

**Indexes**:
- `index_followings_on_followed_id` 
- `index_followings_on_follower_id` 
- `index_followings_on_followed_id_and_follower_id (unique)` 
- `index_followings_on_followed_id_and_created_at` -> for sorting following user by `created_at`
- `index_followings_on_follower_id_and_created_at` -> for sorting follower user by `created_at`

**Foreign Keys**:
- `follower_id` -> `users.id`
- `followed_id` -> `users.id`

## API Endpoints

### Authentication

| Method | Path     | Description                    |
|--------|----------|--------------------------------|
| POST   | `/login` | Login and receive a JWT token  |

**Body Request**
```json
{
    "user_id": 1
}
```
---
**Body Resonse**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3NTczMTc4NjB9.kQ62BprQyV6uNIdcBbupoq2qBs5QdDQbDWPYPGirYiE",
  "user": {
    "id": 1,
    "name": "Alice Cooper"
  }
}
```
use `token` to access another endpoint

---
### Users

| Method | Path                    | Description                                     |
|--------|-------------------------|-------------------------------------------------|
| GET    | `/users`                | List all users                                  |
| POST   | `/users`                | Create a new user                               |
| GET    | `/users/followings`     | Get the users that the current user is following |
| GET    | `/users/followers`      | Get the users who are following the current user |
| POST   | `/users/follow`     | Follow a user by `user_id`                            |
| DELETE | `/users/unfollow`   | Unfollow a user by `user_id`                           |

---

### Sleep Records

| Method | Path                          | Description                                                          |
|--------|-------------------------------|----------------------------------------------------------------------|
| GET    | `/sleep_records`              | Get current user's sleep records                                     |
| POST   | `/sleep_records/clock_in`     | Clock in to start a sleep record (must not already be clocked in)    |
| PATCH  | `/sleep_records/clock_out`    | Clock out from the current sleep record                              |
| GET    | `/sleep_records/followings`   | Get sleep records of followings user, filtered by timeframe and can be sorted by `clocked_in_at`, `clocked_out_at`, and `duration` |
---

>Note:
it will only show clocked_out sleep_records

### Sleep

- **Clock In**: Creates a new `SleepRecord` with `clocked_in_at` default to `Time.now`
    - Fails if there's an unfinished sleep record
- **Clock Out**: Updates the latest sleep record by setting `clocked_out_at` to `Time.now`
    - Fails if there's no active sleep record
    - Will trigger callback to update `duration_hours` column
- **Followings Sleep Records**:
    - Can be filter by timeframe using `from` and `to` query parameters (default: last week from today):
    ```
    GET /sleep_records/followings?from=2025-08-01&to=2025-08ll-10
    ```
    - Can be sorted by `clocked_in_at`, `clocked_out_at`, and `duration`, default sorting is `clocked_in_at`. Direction can be `desc` or `asc`
     ```
    GET /sleep_records/followings?sort_by=duration&direction=desc
    ```

---

### Commands

```bash
bundle install          # Install dependencies

rails db:drop           # [AWARE] Drop db, will follow the configuration on database.yml
rails db:create         # Create db, will follow the configuration on database.yml
rails db:migrate        # Runs migrations
rails db:seed           # Generate seed data
bin/bundle exec rspec   # Run RSpec 

rails s                 # Run the server (default: development)
```
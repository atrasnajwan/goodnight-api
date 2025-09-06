class SleepRecordsController < ApplicationController
    before_action :authenticate_user

    def index
        sort_by = params[:sort_by] || "clocked_in_at"
        direction = params[:direction] == "desc" ? "desc" : "asc"

        # Map duration to duration_hours
        sort_by = "duration_hours" if sort_by == "duration"

        # Validate the sort_by parameter
        unless [ "clocked_in_at", "clocked_out_at", "duration_hours" ].include?(sort_by)
            render json: {
                message: "Invalid sort_by parameter",
                error: "Only clocked_in_at, clocked_out_at, and duration are allowed"
              }, status: :unprocessable_content
            return
        end

        query = current_user.sleep_records.order("#{sort_by} #{direction}")
        pagination, sleep_records = pagy(
                                        query,
                                        limit: params[:per_page] || 10,
                                        page: params[:page] || 1
                                    )

        render json: {
            data: ActiveModelSerializers::SerializableResource.new(sleep_records, each_serializer: SleepRecordSerializer),
            meta: pagination_meta(pagination)
        }
    end

    def clock_in
        current_sleep = SleepRecord.find_by(user: current_user, clocked_out_at: nil)

        # can't clock in if not clocked out before
        if current_sleep.present?
            render json: {
                message: "Already clocked in",
                error: "You must clock out before clock in again"
              }, status: :unprocessable_content
        else
            new_sleep_record = SleepRecord.new(user: current_user)

            if new_sleep_record.save
                render json: new_sleep_record, status: :created
            else
                render json: { errors: new_sleep_record.errors }, status: :unprocessable_content
            end
        end
    end

     def clock_out
        # get un-clocked out sleep record from current/logged user
        current_sleep = current_user.sleep_records.find_by(clocked_out_at: nil)

        if current_sleep.present?
            current_sleep.update!(clocked_out_at: Time.now)

            render json: current_sleep
        else
            render json: {
                message: "Already clocked out",
                error: "Can't clock out sleep that you already clocked out"
            }, status: :unprocessable_content
        end
    end
end

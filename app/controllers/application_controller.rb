class ApplicationController < ActionController::API
    include Pagy::Backend

    # handle if got wrong page/out of scope page
    rescue_from Pagy::OverflowError do
      render json: { error: "Page out of range" }, status: :bad_request
    end

    private

    def pagination_meta(pagy)
        {
            current_page: pagy.page,
            next_page: pagy.next,
            prev_page: pagy.prev,
            total_pages: pagy.pages,
            total_count: pagy.count
        }
    end
end

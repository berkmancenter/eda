class UsersController < ApplicationController
    before_filter :authenticate_user!

    def my_notes
        @notes = current_user.notes
        render 'notes/index'
    end

    def my_reading_lists
        @reading_lists = current_user.reading_lists
        render 'reading_lists/index'
    end
end

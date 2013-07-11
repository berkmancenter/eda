class WordsController < ApplicationController
    def index
        if params[:first_letter]
            @words = Word.starts_with(params[:first_letter])
        else
            @words = Word.all
        end
        render :layout => !request.xhr?
    end
    
    def show
        @word = Word.find(params[:id])
        render :layout => !request.xhr?
    end

    def search
        @words = Word.search do
            fulltext params[:q]
        end.results
    end
end

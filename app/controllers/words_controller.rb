class WordsController < ApplicationController
    def index
        @words = Word.all
    end
    
    def show
        @word = Word.find(params[:id])
    end

    def search
        @words = Word.search do
            fulltext params[:q]
        end.results
    end
end

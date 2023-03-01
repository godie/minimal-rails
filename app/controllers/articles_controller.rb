class ArticlesController < ApplicationController

  def index
    render json: {'message': 'Hello World APP'}, status: :ok
  end

end

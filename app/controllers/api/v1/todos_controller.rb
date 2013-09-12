class Api::V1::TodosController < ApplicationController
  
  #before_action :authenticate_user!, only: :token
  before_filter :authenticate_user!, :except => [:index, :show]
  
  def index
    if user_signed_in?
      @todos = Todo.where( user: current_user)
      
      render json: @todos, :status => :ok 
    else
      @todos = Todo.all
      render json:@todos, :status => :ok
    end
  end

  def show
    @todo = Todo.find(params[:id])
    render json: @todo
  end
  
  def create
    @todo = Todo.new( title: params[:todo][:title], 
              is_completed: params[:todo][:is_completed],
              user: current_user
               )
    @todo.save
    
    render json: @todo
    
  end
  
  def update
    
    @todo =  Todo.where(user:current_user).find(params[:id])
    @todo.update(is_completed: params[:todo][:is_completed])
    render json: @todo
    
  end 
  
  def destroy
    @todo = Todo.find params[:id]
    @todo.destroy
    render json:{} 
    
  end
  private
    # Only allow a trusted parameter "white list" through.
    def todo_params
      params[:todo].permit!
    end
  
end

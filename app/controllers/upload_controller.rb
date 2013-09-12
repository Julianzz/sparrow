class UploadController < ApplicationController
  
  def index 
    @pictures = Picture.all
  end
  
  def new
    @picture = Picture.new
  end
  
  def show
    @picture = Picture.find(params[:id])
  end
  
  def destroy
    Picture.delete(params[:id])
    redirect_to :action => 'index'
  end
  
  def create
    @picture = Picture.new(picture_params) 
    if @picture.save
      flash[:notice] = "You have successfully logged out."
      redirect_to :action => 'index'
    else
      render(:action => :new , :notice=> "create failed ")
    end 
  end
  
  def picture
    @picture = Picture.find(params[:id]) 
    send_data(@picture.data, 
        :filename => @picture.name, 
        :type => @picture.content_type, 
        :disposition => "inline")
  end
  
  
  private

  def picture_params
    params.require(:picture).permit(:comment, :uploaded_picture)
  end
  
end

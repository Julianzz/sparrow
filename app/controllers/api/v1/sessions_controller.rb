
class Api::V1::SessionsController < Devise::SessionsController
  def create
    resource = warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    sign_in_and_redirect(resource_name, resource)
  end
 
  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    return render :json => {:success => true}
  end
 
  def failure
    return render :json => {:success => false, :errors => ["Login failed."]}
  end
  
  def destroy
    sign_out :user
    render json: {}, status: :accepted
  end
  
  
  private
  
  def create__
    user = User.find_for_database_authentication(email: params[:session][:email])

    if user && user.valid_password?(params[:session][:password])
    	sign_in user
    	render json: {
    	  session: { id: user.id, email: user.email }
    	}, status: :created
    else
      render json: {
        errors: {
          email: "invalid email or password"
        }
      }, status: :unprocessable_entity
    end
  end
  
end



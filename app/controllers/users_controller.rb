class UsersController < Devise::RegistrationsController

  def create
    build_resource(sign_up_params)

    resource_saved = resource.save_with_payment
    yield resource if block_given?
    if resource_saved
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      @validatable = devise_mapping.validatable?
      if @validatable
        @minimum_password_length = resource_class.password_length.min
      end
      render :new
    end
  end

  def update_payment_show
    @user = current_user
  end

  def update_payment
    @user = User.find(params[:id])
    @user.stripe_card_token = params[:user][:stripe_card_token]
    if @user.update_payment
      redirect_to mileage_records_path, notice: "Thank You!"
    else
      render :update_payment_show
    end
  end

  def help
  end

end

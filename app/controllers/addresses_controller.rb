class AddressesController < ApplicationController
  
  
  # Slightly breaks RESTfulness because no matter what ID a user enters, it's
  # always only their own addresses that are displayed. But we can later reintroduce
  # RESTfulness by checking whether an admin user (who can see anyone's addresses)
  # is logged in and then using the user ID again.
  def index
    if current_user
      @addresses = Address.active.find(:all, :conditions => {:user_id => current_user.id})
    else
      flash[:info] = "You must be logged in to view this page."
      redirect_to account_path
    end
    
  end
  
  def destroy
    if current_user
      @address = Address.find(params[:id])
      if current_user == @address.user
        @address.status = "deleted"
        if @address.save
          flash[:notice] = "Address deleted."
        else
          flash[:error] = "Address could not be deleted." 
        end
        redirect_to account_path
      else
        flash[:error] = "You have no permission to delete this address."
        redirect_to root_path
      end
    end
  end
  
  
  # When editing, we don't actually allow users to change their own addresses.
  # This is to prevent users changing addresses that are associated with old invoices.
  #
  # Alternatively, invoices could be redesigned so that they contain the addresses
  # as full strings instead of address objects, but that would introduce duplication
  # on that level. This is a clear trade-off situation.
  def update
    if current_user
      @address = Address.find(params[:id])
      if current_user == @address.user
        address = Address.new(params[:address])
        address.user = current_user
        if address.save
          @address.update_attributes(:status => 'deleted')
          flash[:notice] = "Address changed."
          redirect_to user_addresses_path(current_user)
        else
          flash[:error] = "The address couldn't be saved."
          render :action => 'edit'
        end
      else
        flash[:error] = "You have no permission to edit this address."
        redirect_to root_path
      end
    end
  end
  
  def edit
     if current_user
      @address = Address.find(params[:id])
      if current_user != @address.user
        flash[:error] = "You have no permission to edit this address."
        redirect_to user_addresses_path(current_user)
      end
    end
  end
  
  def new
    @address = Address.new
  end
  
  def create
    if current_user
      @address = Address.new(params[:address])
      @address.user = current_user
      if @address.save
	flash[:notice] = "Address saved"
	redirect_to user_addresses_path(current_user)
      else
	flash[:error] = "The address couldn't be saved."
	redirect_to user_addresses_path(current_user)
      end
    end
  end
  
  
end

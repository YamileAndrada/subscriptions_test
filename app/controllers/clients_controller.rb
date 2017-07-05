class ClientsController < ApplicationController
  def index
    @clients = Client.all
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)

    if @client.save
      redirect_to clients_path
    else
      render 'new'
    end
  end
  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    redirect_to clients_path
  end
  private def client_params
    params.require(:client).permit(:first_name, :last_name, :street, :city, :state, :email, :postal_code, :country_code, :credit_card_id)
  end
end

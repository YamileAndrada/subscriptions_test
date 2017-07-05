include PayPal::SDK::REST
class SubscriptionsController < ApplicationController
  def index
    @subscriptions = Subscription.all
  end
  def new
    @subscription = Subscription.new
    @plan = params[:plan]
    @client = params[:client]
    @client_data = Client.find(params[:client])
    # @client_data.update_attribute(:credit_card_id, nil)

    if @client_data.credit_card_id
      @credit_card = CreditCard.find( @client_data.credit_card_id )
      logger.info @credit_card
      logger.info @subscription
      @subscription.card_type = @credit_card.type
      @subscription.card_number = @credit_card.number
      @subscription.card_expires_on =  Date.new(@credit_card.expire_year, @credit_card.expire_month, 27)
    end
  end
  def create
    @plan = BillingPlan.find(params[:plan])
    @client = Client.find(params[:client])
    @agreementAttributes = {
      :name => "Agreement for #{@plan.name}",
      :description => "Agreement",
      :start_date => Time.now.tomorrow.utc.iso8601,
      :plan => {
        :id => @plan.plan_id
      },
      :shipping_address => {
        :line1 => @client.street,
        :city => @client.city,
        :state => @client.state,
        :postal_code => "#{ @client.postal_code}",
        :country_code => @client.country_code
      }
    }

    if params[:subscription][:payment_method] == "credit_card"
      @payer = Payer.new()
      logger.info "payer[#{@payer}] 88888888888888888888888888888888888888"
      if @client.credit_card_id.nil?
        @credit_card = CreditCard.new({
          # ###CreditCard
          # A resource representing a credit card that can be
          # used to fund a payment.
          :type => params[:subscription][:card_type],
          :number => params[:subscription][:card_number],
          :expire_month => params[:subscription]["card_expires_on(2i)"].to_i,
          :expire_year => params[:subscription]["card_expires_on(1i)"].to_i,
          :cvv2 =>  params[:subscription][:card_verification],
          :first_name => @client.first_name,
          :last_name => @client.last_name,
            # ###Address
            # Base Address object used as shipping or billing
            # address in a payment. [Optional]
          :billing_address => {
            :line1 => @client.street,
            :city => @client.city,
            :state => @client.state,
            :postal_code => @client.postal_code,
            :country_code => @client.country_code
          }})

        if @credit_card.create
          logger.info "CreditCard[#{@credit_card.id}] created successfully"
          @client.update_attribute(:credit_card_id, @credit_card.id)
          @agreementAttributes[:payer] = {
            :payer_info => {
              :email => @client.email
            },
            :payment_method => 'credit_card',
            :funding_instruments => [{
              :credit_card_token => {
                :credit_card_id => @credit_card.id,
                :payer_id => @payer.id
              }
          }]}
        end
      else
        @credit_card = CreditCard.find( @client.credit_card_id )
        debugger
        @agreementAttributes[:payer] = {
            :payer_info => {
              :email => @client.email
            },
            :payment_method => 'credit_card',
            :funding_instruments => [{
              :credit_card_token => {
                :credit_card_id => @credit_card.id
              }}
            ]}
      end
    else
      @agreementAttributes[:payer_info] = {
          :email => @client.email
      }
      @agreementAttributes[:payer] = {
            :payment_method => "paypal"
      }
    end

    logger.info "11111111111111111111111111111111111111111111111111111111111"
    logger.info @agreementAttributes
    logger.info "11111111111111111111111111111111111111111111111111111111111"
    @agreement = Agreement.new(@agreementAttributes)

    begin
      if @agreement.create
        if @agreement.links and @redirect_url = @agreement.links.find{|v| v.rel == "approval_url" }
          @redirect_url = @redirect_url.href
          logger.info "Redirect: **************** #{@redirect_url}"
          redirect_to @redirect_url
        else
          # Credit card case no returns urls to approval directly the created object
          @subscription = Subscription.new(card_type: params[:subscription][:card_type], plan_id: @plan.plan_id, client_id: @client.id, agreement_id: @agreement.id, payment_method: params[:subscription][:payment_method] )
          debugger
          @subscription.save
          redirect_to clients_path
        end
      else
        logger.info @agreement.error.inspect
        redirect_to clients_path
      end
    rescue => error
      logger.info "##########ERROR ON CREATION  #{error.inspect}  ##############################33"
      redirect_to clients_path
    end
  end

  def execute
    @agreement = Agreement.new( token: params[:token] )
    if @agreement.execute()

      logger.info "agreement was executed: #{@agreement.id}***************************************"
    else
      logger.error  @agreement.error.inspect
    end
    redirect_to clients_path
  end
end

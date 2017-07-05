include PayPal::SDK::REST
class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    def create
    @webhook = Webhook.new({
        :url => "https://0b4bd5dd.ngrok.io/paypal_webhook",
        :event_types => [
            {
                :name => "BILLING.SUBSCRIPTION.CREATED"
            },
            {
                :name => "BILLING.SUBSCRIPTION.CANCELLED"
            },
            {
                :name => "BILLING.SUBSCRIPTION.SUSPENDED"
            },
            {
                :name => "BILLING.SUBSCRIPTION.RE-ACTIVATED"
            },
            {
                :name => "BILLING.PLAN.CREATED"
            },
            {
                :name => "BILLING.PLAN.UPDATED"
            },
            {
                :name => "PAYMENT.CAPTURE.COMPLETED"
            },
            {
                :name => "PAYMENT.CAPTURE.DENIED"
            },
            {
                :name => "PAYMENT.CAPTURE.PENDING"
            },
            {
                :name => "PAYMENT.CAPTURE.REFUNDED"
            },
            {
                :name => "PAYMENT.CAPTURE.REVERSED"
            },
            {
                :name => "PAYMENT.AUTHORIZATION.CREATED"
            },
            {
                :name => "PAYMENT.SALE.COMPLETED"
            },
            {
                :name => "PAYMENT.SALE.DENIED"
            },
            {
                :name => "PAYMENT.SALE.PENDING"
            },
            {
                :name => "PAYMENT.SALE.REVERSED"
            }
        ]
    })

    if @webhook.create
      logger.info "Webhook[#{@webhook.id}] created successfully"
    else
      ogger.info "error creating webhooks"
      logger.error @webhook.error.inspect
    end

    redirect_to webhooks_path
  end

  def index
    @webhooks = Webhook.all.webhooks
    if @webhooks[0] and @webhooks[0].id
      # To filter the response, include one or more optional query string parameters. You can specify a maximum date range of 45 days.
      @recentEvents = WebhookEvent.search(100,Time.now.yesterday.iso8601, Time.now.tomorrow.iso8601).events
    else
      @webhooks = []
      @recentEvents = []
    end
  end

  def paypal_webhook
    logger.info " Webhook is working"
    if params[:txn_id]
      logger.info "Transaction id  #{params[:txn_id]} *********************************************"
    end
    if params[:event_type]
        logger.info "#########################################################################################################"
        logger.info " Webhook Event Name #{params[:event_type]}    "
        logger.info "#########################################################################################################"
    else
      if params[:txn_type]
        if params[:txn_type] == "send_money"
          logger.info "event received: send_money  #{params[:payment_gross]} from #{params[:payer_email]} "
        else
          logger.info " event received:  Payment status #{params[:payment_status]} #{params[:payment_type]} "
        end
      end
    end
  end

  def destroy
    @webhook = Webhook.get(params[:id])
    if @webhook.delete
    logger.info "Webhook[#{@webhook.id}] deleted successfully"
    else
      logger.error "Unable to delete Webhook[#{@webhook.id}]"
      logger.error @webhook.error.inspect
    end
    redirect_to webhooks_path
  end
end

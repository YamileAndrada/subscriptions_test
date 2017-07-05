include PayPal::SDK::REST
class BillingPlansController < ApplicationController
  def current_client
    @client
  end
  def index
    @billing_plans = BillingPlan.all
    if params[:client]
      @client = Client.find(params[:client])
    end
  end
  def new
    @billing_plan = BillingPlan.new
    @billing_plan.name = ''
  end
  def create
    @billing_plan = BillingPlan.new(billing_plan_params)
    if @billing_plan.save
        @plan = Plan.new({
          :name => @billing_plan.name,
          :description => @billing_plan.description,
          :type => "INFINITE",
          :payment_definitions => [
              {
                  :name => "Regular Payments",
                  :type => "REGULAR",
                  :frequency => "MONTH",
                  :frequency_interval => "1",
                  :amount => {
                      :value => @billing_plan.amount,
                      :currency => @billing_plan.currency
                  },
                  :cycles => "0"
              }
          ],

          :merchant_preferences => {
              :setup_fee => {
                  :value => "2.5",
                  :currency => "USD"
              },
              :return_url => "https://0b4bd5dd.ngrok.io/ConfirmSuscription",
              :cancel_url => "https://0b4bd5dd.ngrok.io",
              :auto_bill_amount => "YES",
              :initial_fail_amount_action => "CONTINUE",
              :max_fail_attempts => "3"
          }
        })

      if params[:trial]
        @plan.payment_definitions.push({
          :name => "Regular Payments",
          :type => "TRIAL",
          :frequency => @billing_plan.trial_period,
          :frequency_interval => "1",
          :amount => {
            :value => 0,
            :currency => @billing_plan.currency
          },
          :cycles => "1"
        })

      end
       # Create plan
      if @plan.create
        logger.info "Plan creado: #{@plan.id}"
        # Plan update activation object
        plan_update = {
          :op => 'replace',
          :path => '/',
          :value => {
            :state => 'ACTIVE'
          }
        }
        @billing_plan.update_attribute(:plan_id, @plan.id)
        # Activate plan
        if @plan and @plan.update(plan_update)
          puts("Billing plan activated with ID [#{@plan.id}]")
          logger.info "Billing plan was activated: #{@plan.id}"
        else
          logger.error  @plan.error.inspect
        end
      else
        logger.error  @plan.error.inspect
      end
      redirect_to billing_plans_path
    else
      render 'new'
    end
  end

  def destroy
    @billing_plan = BillingPlan.find(params[:id])

    if @billing_plan.plan_id
      plan_update = {
        :op => 'replace',
        :path => '/',
        :value => {
        :state => 'DELETED'
        }
      }
      @plan = Plan.find(@billing_plan.plan_id)
      @plan.update(plan_update)
    end
    @billing_plan.destroy
    redirect_to billing_plans_path
  end

  private
  def billing_plan_params
    params.require(:billing_plan).permit(:name, :description, :amount, :currency, :trial, :trial_period, :plan_id, :client_id)
  end
end
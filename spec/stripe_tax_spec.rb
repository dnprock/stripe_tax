require 'spec_helper'

def get_stripe_token(exp_year = 2014, card_number = "4242424242424242", cvc = 314)
  token = Stripe::Token.create(
      :card => {
      :number => card_number,
      :exp_month => 3,
      :exp_year => exp_year
    },
  )
  
  return token.id
end

describe StripeTax do
  
  let(:invoice_event_with_coupon) { 
    json = JSON.parse('
      {
        "id": "evt_1cQGraIFs7I7JQ",
        "created": 1365551086,
        "livemode": false,
        "type": "invoice.created",
        "data": {
          "object": {
            "date": 1365551086,
            "id": "in_1cQGyWmQRoaSFh",
            "period_start": 1365551068,
            "period_end": 1365551073,
            "lines": {
              "object": "list",
              "count": 1,
              "url": "/v1/invoices/in_1cQGyWmQRoaSFh/lines",
              "data": [
                {
                  "id": "su_1cQGJGt1nNdp5w",
                  "object": "line_item",
                  "type": "subscription",
                  "livemode": false,
                  "amount": 2000,
                  "currency": "usd",
                  "proration": false,
                  "period": {
                    "start": 1365551073,
                    "end": 1368143073
                  },
                  "quantity": 1,
                  "plan": {
                    "interval": "month",
                    "name": "TrialTest",
                    "amount": 2000,
                    "currency": "usd",
                    "id": "TRIALTEST",
                    "object": "plan",
                    "livemode": false,
                    "interval_count": 1,
                    "trial_period_days": 30
                  },
                  "description": null
                }
              ]
            },
            "subtotal": 2000,
            "total": 1500,
            "customer": "cus_1cQFYs0P2VfDlC",
            "object": "invoice",
            "attempted": false,
            "closed": false,
            "paid": false,
            "livemode": false,
            "attempt_count": 0,
            "amount_due": 1500,
            "currency": "usd",
            "starting_balance": 0,
            "ending_balance": null,
            "next_payment_attempt": 1365554686,
            "charge": null,
            "discount": {
              "coupon": {
                "id": "25OFF",
                "percent_off": 25,
                "amount_off": null,
                "currency": null,
                "object": "coupon",
                "livemode": false,
                "duration": "repeating",
                "redeem_by": null,
                "max_redemptions": null,
                "times_redeemed": 1,
                "duration_in_months": 3
              },
              "start": 1365551037,
              "object": "discount",
              "customer": "cus_1cQFYs0P2VfDlC",
              "end": 1373413437
            }
          }
        },
        "object": "event",
        "pending_webhooks": 1
      }
      ')
    obj = Stripe::Util.convert_to_stripe_object(json, '')
    obj
  }
  
  it 'sales tax for WA' do
    tax = StripeTax.calculate(10000, 'WA')
    tax.should eq(950)
  end
  
  before(:all) do
    if ENV['STRIPE_API_KEY'] then
      Stripe.api_key = ENV['STRIPE_API_KEY']
    
      @plan = Stripe::Plan.create(
        :amount => 2000,
        :interval => 'month',
        :name => 'Test',
        :currency => 'usd',
        :id => 'TEST')
      
      @trial_plan = Stripe::Plan.create(
        :amount => 2000,
        :interval => 'month',
        :name => 'TrialTest',
        :currency => 'usd',
        :id => 'TRIALTEST',
        :trial_period_days => 30)
      
      @coupon = Stripe::Coupon.create(
                :percent_off => 25,
                :duration => 'repeating',
                :duration_in_months => 3,
                :id => '25OFF')
    end
  end
  
  after(:all) do
    # clean up
    if ENV['STRIPE_API_KEY'] then
      @plan.delete
      @trial_plan.delete
      @coupon.delete
    end
  end
  
  it 'create customer with plan' do
    if !ENV['STRIPE_API_KEY'] then
      puts 'Please specify STRIPE_API_KEY env variable. Skip test.'
    else
      customer = StripeTax.create_customer(@plan.id, '',
                  'test@example.com', 'WA', get_stripe_token)
      
      charges = Stripe::Charge.all(:customer => customer.id)
      
      charges.count.should eq(1)
      charges.data[0].amount.should eq(2190) # 2000 * 1.095
      
      # clean up
      customer.delete
    end
  end
  
  it 'create customer with plan and percent coupon' do
    if !ENV['STRIPE_API_KEY'] then
      puts 'Please specify STRIPE_API_KEY env variable. Skip test.'
    else
      customer = StripeTax.create_customer(@plan.id, @coupon.id,
                  'test@example.com', 'WA', get_stripe_token)
      
      charges = Stripe::Charge.all(:customer => customer.id)
      
      charges.count.should eq(1)
      charges.data[0].amount.should eq(1642) # 2000 * 0.75 * 1.095
      
      # clean up
      customer.delete
    end
  end
  
  it 'add tax to recurring subscription' do
    if !ENV['STRIPE_API_KEY'] then
      puts 'Please specify STRIPE_API_KEY env variable. Skip test.'
    else

      #customer = Stripe::Customer.create(
      #              :email => 'test@example.com',
      #              :card => get_stripe_token,
      #              :coupon => @coupon.id
      #            )

      #invoice_item = StripeTax.recurring_add_tax(invoice_event_with_coupon, 'WA')
      #invoice_item.should_not be_nil
      
      #customer.delete
    end
  end
end

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
  it 'sales tax for WA' do
    tax = StripeTax.calculate(10000, 'WA')
    tax.should eq(950)
  end
  
  before(:each) do
    if ENV['STRIPE_API_KEY'] then
      Stripe.api_key = ENV['STRIPE_API_KEY']
    
      @plan = Stripe::Plan.create(
        :amount => 2000,
        :interval => 'month',
        :name => 'Test Plan',
        :currency => 'usd',
        :id => 'TESTPLAN')
      
      @coupon = Stripe::Coupon.create(
                :percent_off => 25,
                :duration => 'repeating',
                :duration_in_months => 3,
                :id => '25OFF')
    end
  end
  
  after(:each) do
    # clean up
    if ENV['STRIPE_API_KEY'] then
      @plan.delete
      @coupon.delete
    end
  end
  
  it 'create customer with plan' do
    if !ENV['STRIPE_API_KEY'] then
      puts 'Please specify STRIPE_API_KEY env variable. Skip test.'
    else
      customer = StripeTax.create_customer(@plan.id, '', 'test@example.com', 'WA', get_stripe_token)
      
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
      customer = StripeTax.create_customer(@plan.id, @coupon.id, 'test@example.com', 'WA', get_stripe_token)
      
      charges = Stripe::Charge.all(:customer => customer.id)
      
      charges.count.should eq(1)
      charges.data[0].amount.should eq(1642) # 2000 * 0.75 * 1.095
      
      # clean up
      customer.delete
    end
  end
end

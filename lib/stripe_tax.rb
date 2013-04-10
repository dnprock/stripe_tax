class StripeTax
  # rates from here:
  # http://www.salestaxinstitute.com/resources/rates
  def self.get_rate(state)
    rates = {
      'AL' => 0.04,
      'AK' => 0.00,
      'AZ' => 0.066,
      'AR' => 0.06,
      'CA' => 0.075,
      'CO' => 0.029,
      'CT' => 0.0635,
      'DE' => 0.00,
      'DC' => 0.06,
      'FL' => 0.06,
      'GA' => 0.04,
      'HI' => 0.04,
      'ID' => 0.06,
      'IL' => 0.0625,
      'IN' => 0.07,
      'IA' => 0.06,
      'KS' => 0.063,
      'KY' => 0.06,
      'LA' => 0.04,
      'ME' => 0.05,
      'MD' => 0.06,
      'MA' => 0.0625,
      'MI' => 0.06,
      'MN' => 0.06875,
      'MS' => 0.07,
      'MO' => 0.04225,
      'MT' => 0.00,
      'NE' => 0.055,
      'NV' => 0.0685,
      'NH' => 0.00,
      'NJ' => 0.07,
      'NM' => 0.05125,
      'NY' => 0.04,
      'NC' => 0.0475,
      'ND' => 0.05,
      'OH' => 0.055,
      'OK' => 0.045,
      'OR' => 0.00,
      'PA' => 0.06,
      'PR' => 0.07,
      'RI' => 0.055,
      'SC' => 0.06,
      'SD' => 0.04,
      'TN' => 0.07,
      'TX' => 0.0625,
      'UT' => 0.047,
      'VT' => 0.06,
      'VA' => 0.04,
      'WA' => 0.095,
      'WV' => 0.06,
      'WI' => 0.05,
      'WY' => 0.04
     }
    rates[state]
  end
  
  def self.calculate(charge, state)
    rate = get_rate(state)
    ((rate * charge.to_f / 100).round(2) * 100).to_i
  end

  # this method creates new customer with tax
  def self.create_customer(planID, coupon, email, state, stripe_card_token)
    plan = Stripe::Plan.retrieve(planID)
    charge_amount = plan.amount
    
    if coupon.length > 0
      customer = Stripe::Customer.create(
        :email => email,
        :card => stripe_card_token,
        :coupon => coupon
      )
      
      # retrieve coupon to calculate sales tax for dollar off amount
      coupon = Stripe::Coupon.retrieve(coupon)
      if coupon.amount_off != nil then
        charge_amount = charge_amount - coupon.amount_off
      end
    else
      customer = Stripe::Customer.create(
        :email => email,
        :card => stripe_card_token
      )
    end
    
    if state != '' then
      # create invoice item for sales tax
      sales_tax = calculate(charge_amount, state)
    
      sales_tax_item = Stripe::InvoiceItem.create(
          :customer => customer.id,
          :amount => sales_tax,
          :currency => plan.currency,
          :description => "Sales tax for " + state
      )
    end
    
    customer.update_subscription(:plan => planID)
    
    return customer
  end

  # create sales tax invoice item for next subscription
  # call this in invoice.created
  def self.recurring_add_tax(event, state)
    # next subscription, invoice should be open
    if event.data.object.closed == false then
      charge_amount = event.data.object.lines.data[0].plan.amount

      if event.data.object.discount then
        # retrieve coupon to calculate sales tax for dollar off amount
        coupon = event.data.object.discount.coupon
        if coupon.amount_off != nil then
          charge_amount = charge_amount - coupon.amount_off
        end
      end

      # create invoice item for sales tax
      sales_tax = calculate(charge_amount, state)

      sales_tax_item = Stripe::InvoiceItem.create(
              :customer => event.data.object.customer,
              :amount => sales_tax,
              :currency => event.data.object.lines.data[0].plan.currency,
              :description => "Sales tax for " + state
        )
      sales_tax_item
    end
  end
end

class SalesTax
  # rates from here:
  # http://www.salestaxinstitute.com/resources/rates
  def get_sales_tax_rate(state)
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
  
  def calculate_sales_tax(charge, state)
    rate = get_sales_tax_rate(state)
    ((rate * charge.to_f / 100).round(2) * 100).to_i
  end
end

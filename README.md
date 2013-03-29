This gem helps you calculate sales tax for your Stripe customer subscription.

Include stripe_tax gem, call StripeTax.create_customer instead of Stripe::Customer.create.

In invoice.created callback, call StripeTax.recurring_add_tax.

Run Test
--------
STRIPE_API_KEY=api_key rspec spec/stripe_tax_spec.rb

Contact
-------
Phuoc Do

dnprock@gmail.com

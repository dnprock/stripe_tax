License MIT.

This gem helps you calculate sales tax for your Stripe customer subscription.

Include stripe_tax gem, call StripeTax.create_customer.

In invoice.created callback, call StripeTax.recurring_add_tax.

Phuoc Do
dnprock@gmail.com
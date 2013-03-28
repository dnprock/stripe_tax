Gem::Specification.new do |s|
  s.name        = 'stripe_tax'
  s.version     = '0.0.1'
  s.summary     = "Calculate sales tax for Stripe"
  s.description = "Stripe payment gateway accepts credit card charge. It doesn't handle sales tax calculation. This gem provides a wrapper for how to charge sales tax through Stripe."
  s.authors     = ["Phuoc Do"]
  s.email       = 'dnprock@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://twitter.com/DoPhuoc'
end

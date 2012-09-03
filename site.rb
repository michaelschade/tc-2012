require 'sinatra'
require 'stripe'

Stripe.api_key = 'sk_0JzIVHOD3WeYgfMnsLGQy7vu9MoVh'

get '/' do
  erb :index
end

post '/register' do
  begin
    Stripe::Customer.create(
      :plan => 'emerge',
      :card => params[:stripeToken]
    )
  rescue Stripe::StripeError => error
    redirect to('/')
  end

  erb :registered
end

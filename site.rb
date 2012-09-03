require 'sinatra'
require 'stripe'

Stripe.api_key = 'sk_0JzIVHOD3WeYgfMnsLGQy7vu9MoVh'

get '/' do
  erb :index
end

post '/register' do
  begin
    Stripe::Charge.create(
      :amount       => 4200,
      :currency     => 'usd',
      :card         => params[:stripeToken],
      :description  => 'Conference pass for TE Emerge'
    )
  rescue Stripe::StripeError => error
    redirect to('/')
  end

  erb :registered
end

require 'sinatra'
require 'stripe'
require 'json'

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

# Phase 3: we add webhooks; talk about how these can be useful
post '/webhooks/stripe' do
  event_json = JSON.parse(request.body.read)
  event = Stripe::Event.retrieve(event_json['id'])
  puts event.inspect
end

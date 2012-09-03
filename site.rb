require 'sinatra'
require 'stripe'
require 'json'
require 'rest-client'
require "redis"

enable :sessions
redis = Redis.new

APP_KEY = 'sk_0JzIVHOD3WeYgfMnsLGQy7vu9MoVh'
APP_ID  = 'ca_0KDX3WnQkEHXF3optBDtLgcWrZgJkbjt'

get '/' do
  event = redis.get(params[:event] || 'emerge')
  event = JSON.parse(event)
  @publishable_key = event['publishable_key']

  erb :index
end

post '/register' do
  event = redis.get(params[:event] || 'emerge')
  event = JSON.parse(event)

  Stripe.api_key = event['access_token']

  begin
    Stripe::Charge.create(
      :amount       => 4200,
      :currency     => 'usd',
      :card         => params[:stripeToken],
      :description  => "Conference pass for #{ params[:event] }"
    )
  rescue Stripe::StripeError => error
    redirect to('/')
  end

  erb :registered
end

post '/webhooks/stripe' do
  event_json = JSON.parse(request.body.read)
  event = Stripe::Event.retrieve(event_json['id'])
  puts event.inspect
end

get '/host' do
  erb :host_event
end

post '/host' do
  session[:event_name] = params[:event_name]
  redirect to("https://connect.stripe.com/oauth/authorize?client_id=#{ APP_ID }&scope=read_write&response_type=code")
end

get '/login/stripe' do
  data = RestClient.post('https://connect.stripe.com/oauth/token', {
    :code       => params[:code],
    :grant_type => 'authorization_code',
    :client_id  => APP_ID
  }, :Authorization => "Bearer #{ APP_KEY }")
  data = JSON.parse(data)

  redis.set(session[:event_name], {
    :user_id          => data['stripe_user_id'],
    :access_token     => data['access_token'],
    :publishable_key  => data['stripe_publishable_key']
  }.to_json)

  redirect to('/host')
end

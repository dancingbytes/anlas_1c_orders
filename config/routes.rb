# encoding: utf-8
Anlas1cOrders::Engine.routes.draw do

  match  'anlas_exchange_orders/:exchange_url'  => 'anlas_exchange_orders#index',
    :format => false, :via => [:post, :put, :delete, :options, :patch, :get, :head]

  match  'anlas_exchange_orders'                => 'anlas_exchange_orders#error',
    :format => false, :via => [:post, :put, :delete, :options, :patch, :get, :head]

end # draw

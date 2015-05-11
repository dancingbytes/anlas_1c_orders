# encoding: utf-8
Anlas1cOrders::Engine.routes.draw do

  get  'anlas_exchange_orders/:exchange_url'  => 'anlas_exchange_orders#index'
  get  'anlas_exchange_orders'                => 'anlas_exchange_orders#error'

end # draw

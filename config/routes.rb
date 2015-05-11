# encoding: utf-8
Anlas1cOrders::Engine.routes.draw do

  get  'anlas_1c_orders/:exchange_url'  => 'anlas_1c_orders#index'
  get  'anlas_1c_orders'                => 'anlas_1c_orders#error'

end # draw

# encoding: utf-8
require 'zip'
require 'fileutils'
require 'yaml'
require 'nokogiri'

require 'anlas_1c_orders/version'
require 'anlas_1c_orders/xml'
require 'anlas_1c_orders/base'

module Anlas1cOrders

  extend self

  def exchange(name, login: nil, pass: nil)

    @params       ||= {}
    @params[name] = { login: login, pass: pass }
    self

  end # exchange

  def params

    @params ||= {}
    @params

  end # params

  def keys
    params.keys
  end # keys

end # Anlas1cOrders

if defined?(::Rails)
  require 'anlas_1c_orders/engine'
  require 'anlas_1c_orders/railtie'
end

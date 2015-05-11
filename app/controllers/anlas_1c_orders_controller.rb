# encoding: utf-8
class Anlas1cOrderController < ApplicationController

  unloadable

  before_filter :auth
  skip_before_filter :verify_authenticity_token

  # GET /anlas_1c_orders/:delivery_type
  def index

    case params[:mode]

      when 'init'
        render(:text => "zip=yes\nfile_limit=9999999999999999999", :layout => false) and return

      when 'checkauth'
        render(:text => "success\nanlas_1c_orders\n#{rand(9999999999)}", :layout => false) and return

      when 'success'
        render(:text => "success", :layout => false) and return

      when 'query'

        req       = ::Anlas1cOrders::Base.new(params[:exchange_url])
        file_name = req.to_file

        if file_name && ::File.exist?(file_name)

          begin

            send_file(File.read(file_name),
              :type         => "application/zip",
              :disposition  => "inline"
            )

          ensure
            ::FileUtils.rm(file_name, force: true)
          end

        else
          render(:text => "failure\nNot found", :layout => false) and return
        end

      else
        render(:text => "failure\nParameter is incorrect", :layout => false) and return

    end # case

  end # index

  # GET /anlas_1c_orders
  def error
    render(:text => "failure\nUrl is incorrect", :layout => false) and return
  end # error

  private

  def auth

    authenticate_or_request_with_http_basic do |login, password|

      ::Anlas1cOrders::Base.auth?(
        params[:exchange_url],
        login,
        password
      )

    end

  end # auth

end # Anlas1cOrderController

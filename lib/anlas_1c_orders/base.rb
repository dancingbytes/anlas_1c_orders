# encoding: utf-8
module Anlas1cOrders

  class Base

    class << self

      def auth?(name, login, pass)
        new(name).auth?
      end # auth?

    end # class << self

    def initialize(name)

      @name   = name
      @el     = ::Anlas1cOrders.params[name] || {}
      @login  = @el[:login]
      @pass   = @el[:pass]

    end # new

    def exist?
      !@el.empty?
    end # exist?

    def auth?(login, pass)
      @login.nil? || (@login == login && @pass == pass)
    end # auth?

    def to_file

      return unless exist?

      orders = ::Order.where(exchanged: false, delivery_type_id: @name)
      return unless orders.exists?

      files = []
      orders.each { |order|
        files << ::Anlas1cOrders::Xml.create(order)
      }
      zip_files(files)

    end # to_file

    private

    def zip_files(files, file_name = nil)

      file_name ||= ::File.join("/tmp", "#{::Time.now.to_i}-#{rand}.zip")

      begin

        zip = ::Zip::File.open(file_name, ::Zip::File::CREATE)
        files.each { |fl|
          zip.add(::File.basename(fl), fl)
        }
        zip.close

      rescue => ex
        puts "#{ex.inspect}"
      end

      file_name

    end # zip_file

  end # Base

end # Anlas1cOrders

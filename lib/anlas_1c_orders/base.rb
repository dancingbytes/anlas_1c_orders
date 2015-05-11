# encoding: utf-8
module Anlas1cOrders

  class Base

    class << self

      def auth?(name, login, pass)
        new(name).auth?(login, pass)
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

      # Архивируем
      file_name = zip_files(files)

      # Помечаем заказы обаботанными
      orders.with(safe: true).update_all({ exchanged: true })

      # Возвращаем название файла
      file_name

    end # to_file

    private

    def zip_files(files, file_name = nil)

      file_name ||= ::File.join("/tmp", "#{::Time.now.to_i}-#{rand}.zip")

      begin

        ::Zip::File.open(file_name, ::Zip::File::CREATE) { |zip|

          files.each { |fl|
            zip.add(::File.basename(fl), fl)
          }

        }

        # Удаляем файлы
        files.each { |fl|
          ::FileUtils.rm(fl, force: true)
        }

      rescue => ex
        puts "[Anlas1cOrders::Base.zip_file] #{ex.inspect}"
      end

      file_name

    end # zip_file

  end # Base

end # Anlas1cOrders

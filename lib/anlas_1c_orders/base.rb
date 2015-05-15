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
      @zip    = @el[:zip] == true

    end # new

    def exist?
      !@el.empty?
    end # exist?

    def auth?(login, pass)
      @login.nil? || (@login == login && @pass == pass)
    end # auth?

    def mime_type
      @zip ? "application/zip" : "text/xml"
    end # mime_type

    def encoding
      @el[:encoding] || 'UTF-8'
    end # encoding

    def type
      @type ||= "#{self.mime_type}; charset=#{self.encoding}"
    end # type

    def to_file

      # Если указанная выгрузка не найдена -- завершаем работу
      return unless exist?

      # Выбираем заказы на обработку
      orders = ::Order.where(state_code: 1, accepted: false, delivery_type_id: @name)

      # Формируем файл выгрузки
      file_name = ::Anlas1cOrders::Xml.create(orders, self.encoding)

      # Архивируем -- если задано
      file_name = zip_files(file_name) if @zip

      # Помечаем заказы обаботанными
      orders.with(safe: true).update_all({ state_code: 203 })

      # Возвращаем название файла
      file_name

    end # to_file

    private

    def zip_files(file_name, target_file_name = nil)

      target_file_name ||= ::File.join("/tmp", "#{::Time.now.to_i}-#{rand}.zip")

      begin

        ::Zip::File.open(target_file_name, ::Zip::File::CREATE) { |zip|
          zip.add(::File.basename(file_name), file_name)
        }

        # Удаляем файлы
        ::FileUtils.rm(file_name, force: true)

      rescue => ex
        puts "[Anlas1cOrders::Base.zip_file] #{ex.inspect}"
      end

      target_file_name

    end # zip_file

  end # Base

end # Anlas1cOrders

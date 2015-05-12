# encoding: utf-8
module Anlas1cOrders

  class Xml

    class << self

      def create(orders)
        new(orders).create
      end # create

    end # class << self

    def initialize(orders)
      @orders = orders
    end # new

    def create

      file_name = ::File.join(::Rails.root, "tmp", "#{::Time.now.to_i}-#{rand}.xml")
      create_xml(file_name)
      file_name

    end # create

    private

    def create_xml(file_name)

      number  = ::Time.now.to_i.to_s
      date    = ::Time.now.strftime("%Y-%m-%d")
      time    = ::Time.now.strftime("%H:%M:%S")

      builder = ::Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|

        xml.send(:"КоммерческаяИнформация", {
          "ВерсияСхемы"       => "2.03",
          "ДатаФормирования"  => date
        }) {

          @orders.each { |order|

            xml.send(:"Документ") {

              xml.send(:"Ид",           order.uri)
              xml.send(:"Номер",        order.uri)
              xml.send(:"Дата",         date)
              xml.send(:"Время",        time)
              xml.send(:"Комментарий",  nil)

              xml.send(:"ХозОперация",  "Заказ товара")
              xml.send(:"Роль",         "Продавец")
              xml.send(:"Валюта",       "руб")
              xml.send(:"Курс",         1)
              xml.send(:"Сумма",        order.price)

              xml.send(:"Контрагенты") {

                xml.send(:"Контрагент") {

                  xml.send(:"Ид",                 "admin")
                  xml.send(:"Наименование",       "admin")
                  xml.send(:"Роль",               "Покупатель")
                  xml.send(:"ПолноеНаименование", xml_escape(order.fio))
                  xml.send(:"Фамилия",            xml_escape(order.last_name || ""))
                  xml.send(:"Имя",                xml_escape(order.first_name || ""))
                  xml.send(:"Контакты",           order.phone_number || "")

                  xml.send(:"АдресРегистрации")

                  xml.send(:"Представители") {

                    xml.send(:"Представитель") {

                      xml.send(:"Контрагент") {

                        xml.send(:"Отношение",    "Контактное лицо")
                        xml.send(:"ИД",           "b342955a9185c40132d4c1df6b30af2f")
                        xml.send(:"Наименование", "admin")

                      }

                    }

                  }

                } # Контрагент

              } # Контрагенты

              xml.send(:"Товары") {

                order.cart_items.each do |item|

                  xml.send(:"Товар") {

                    xml.send(:"Ид",             item.id.to_s)
                    xml.send(:"ИдКаталога",     "")
                    xml.send(:"Наименование",   xml_escape(item.name))
                    xml.send(:"ЦенаЗаЕдиницу",  item.price)
                    xml.send(:"Количество",     item.count)
                    xml.send(:"Сумма",          item.total_price)

                    xml.send(:"БазоваяЕдиница", "шт", {
                      "Код"                     => "796",
                      "НаименованиеПолное"      => "Штука",
                      "МеждународноеСокращение" => "PCE"
                    })

                    xml.send(:"ЗначенияРеквизитов") {

                      xml.send(:"ЗначениеРеквизита") {

                        xml.send(:"Наименование", "ВидНоменклатуры")
                        xml.send(:"Значение",     "Товар")

                      }

                      xml.send(:"ЗначениеРеквизита") {

                        xml.send(:"Наименование", "ТипНоменклатуры")
                        xml.send(:"Значение",     "Товар")

                      }

                    }

                  } # Товар

                end # items

              } # Товары

              xml.send(:"ЗначенияРеквизитов") {

                xml.send(:"ЗначениеРеквизита") {

                  xml.send(:"Наименование", "Метод оплаты")
                  xml.send(:"Значение",     "Наличный расчет")

                } # ЗначениеРеквизита

                xml.send(:"ЗначениеРеквизита") {

                  xml.send(:"Наименование", "Заказ оплачен")
                  xml.send(:"Значение",     order.payed?)

                } # ЗначениеРеквизита

                xml.send(:"ЗначениеРеквизита") {

                  xml.send(:"Наименование", "Доставка разрешена")
                  xml.send(:"Значение",     "false")

                } # ЗначениеРеквизита

                xml.send(:"ЗначениеРеквизита") {

                  xml.send(:"Наименование", "Отменен")
                  xml.send(:"Значение",     order.canceled?)

                } # ЗначениеРеквизита

                xml.send(:"ЗначениеРеквизита") {

                  xml.send(:"Наименование", "Финальный статус")
                  xml.send(:"Значение",     "false")

                } # ЗначениеРеквизита

                xml.send(:"ЗначениеРеквизита") {

                  xml.send(:"Наименование", "Статус заказа")
                  xml.send(:"Значение",     "Принят")

                } # ЗначениеРеквизита

                xml.send(:"ЗначениеРеквизита") {

                  xml.send(:"Наименование", "Дата изменения статуса")
                  xml.send(:"Значение",     order.created_at.strftime("%Y-%m-%d %H:%M:%S"))

                } # ЗначениеРеквизита

              } # ЗначенияРеквизитов

            } # Документ

          } # each

        } # КоммерческаяИнформация

      end # builder

      ::File.open(file_name, "wb") do |f|
        f.write(builder.to_xml)
      end
      self

    end # create_xml

    def xml_escape(str)

      str.gsub!(/&/, "&amp;")
      str.gsub!(/'/, "&apos;")
      str.gsub!(/"/, "&quot;")
      str.gsub!(/>/, "&gt;")
      str.gsub!(/</, "&lt;")
      str

    end # xml_escape

  end # Xml

end # Anlas1cOrders

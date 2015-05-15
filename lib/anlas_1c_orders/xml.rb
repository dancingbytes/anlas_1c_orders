# encoding: utf-8
module Anlas1cOrders

  class Xml

    class << self

      def create(orders, encoding)
        new(orders, encoding).create
      end # create

    end # class << self

    def initialize(orders, encoding = 'UTF-8')

      @orders   = orders
      @encoding = encoding

    end # new

    def create

      file_name = ::File.join("/tmp", "#{::Time.now.to_i}-#{rand}.xml")
      create_xml(file_name)
      file_name

    end # create

    private

    def create_xml(file_name)

      builder = ::Nokogiri::XML::Builder.new(:encoding => @encoding) do |xml|

        xml.send(:"КоммерческаяИнформация", {
          "ВерсияСхемы"       => "2.05",
          "ДатаФормирования"  => ::Time.now.strftime("%Y-%m-%dТ%H:%M:%S"),
          "ФорматДаты"        => "ДФ=yyyy-MM-dd; ДЛФ=DT",
          "ФорматВремени"     => "ДФ=ЧЧ:мм:сс; ДЛФ=T",
          "РазделительДатаВремя" => "T",
          "ФорматСуммы"       => "ЧЦ=18; ЧДЦ=2; ЧРД=.",
          "ФорматКоличества"  => "ЧЦ=18; ЧДЦ=2; ЧРД=."
        }) {

          @orders.each { |order|

            user = order.user || ::User.new

            xml.send(:"Документ") {

              xml.send(:"Ид",           order.uri)
              xml.send(:"Номер",        order.uri)
              xml.send(:"Дата",         ::Time.now.strftime("%Y-%m-%d"))
              xml.send(:"Время",        ::Time.now.strftime("%H:%M:%S"))
              xml.send(:"Комментарий")

              xml.send(:"ХозОперация",  "Заказ товара")
              xml.send(:"Роль",         "Продавец")
              xml.send(:"Валюта",       "руб")
              xml.send(:"Курс",         1)
              xml.send(:"Сумма",        order.price)

              xml.send(:"Контрагенты") {

                xml.send(:"Контрагент") {

                  xml.send(:"Ид",       to_1c_id(user.id))
                  xml.send(:"Роль",     "Покупатель")

                  if order.legal_entity?
                    legal_entity(xml, order)
                  else
                    physical_person(xml, order)
                  end

                } # Контрагент

              } # Контрагенты

              xml.send(:"Товары") {

                order.cart_items.each do |item|

                  xml.send(:"Товар") {

                    xml.send(:"Ид",             to_1c_id(item.id))
                    xml.send(:"ИдКаталога",     "")
                    xml.send(:"Артикул",        item.marking_of_goods)
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

    def physical_person(xml, order)

      user = order.user || ::User.new

      xml.send(:"Наименование",       xml_escape(order.fio))
      xml.send(:"ПолноеНаименование", xml_escape(order.fio))
      xml.send(:"Фамилия",            xml_escape(order.last_name || ""))
      xml.send(:"Имя",                xml_escape(order.first_name || ""))

      xml.send(:"Контакты") {

        xml.send(:"Контакт") {

          xml.send(:"Тип",        "Почта")
          xml.send(:"Значение",   order.email)

        }

        xml.send(:"Контакт") {

          xml.send(:"Тип",        "ТелефонРабочий")
          xml.send(:"Значение",   order.phone_number)

        }

      }

      xml.send(:"Представители") {

        xml.send(:"Представитель") {

          xml.send(:"Контрагент") {

            xml.send(:"Отношение",    "Контактное лицо")
            xml.send(:"ИД",           to_1c_id(user.id))
            xml.send(:"Наименование", xml_escape(order.fio))

          }

        }

      }

    end # physical_person

    def legal_entity(xml, order)

      user = order.user || ::User.new

      xml.send(:"Наименование",             xml_escape(order.organization))
      xml.send(:"ОфициальноеНаименование",  xml_escape(order.organization))

      xml.send(:"ЮридическийАдрес") {
        xml.send(:"Представление",  xml_escape(order.juridical_address))
      }

      xml.send(:"ИНН",  order.inn)
      xml.send(:"КПП",  order.kpp)

      xml.send(:"Адрес") {
        xml.send(:"Представление",  xml_escape(order.juridical_address))
      }

      xml.send(:"Контакты") {

        xml.send(:"Контакт") {

          xml.send(:"Тип",        "Почта")
          xml.send(:"Значение",   order.email)

        }

        xml.send(:"Контакт") {

          xml.send(:"Тип",        "ТелефонРабочий")
          xml.send(:"Значение",   order.phone_number)

        }

      }

      xml.send(:"Представители") {

        xml.send(:"Представитель") {

          xml.send(:"Контрагент") {

            xml.send(:"Отношение",    "Контактное лицо")
            xml.send(:"ИД",           to_1c_id(user.id))
            xml.send(:"Наименование", xml_escape(order.fio))

          }

        }

      }

    end # legal_entity

    def xml_escape(str)

      str.gsub!(/&/, "&amp;")
      str.gsub!(/'/, "&apos;")
      str.gsub!(/"/, "&quot;")
      str.gsub!(/>/, "&gt;")
      str.gsub!(/</, "&lt;")
      str

    end # xml_escape

    def to_1c_id(str)

      uid = str.to_s.ljust(32, '0')
      "#{uid[0,8]}-#{uid[7,4]}-#{uid[12,4]}-#{uid[16,4]}-#{uid[20,12]}"

    end # to_1c_id

  end # Xml

end # Anlas1cOrders

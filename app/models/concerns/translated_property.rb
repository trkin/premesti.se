require 'active_support/concern'

module TranslatedProperty
  extend ActiveSupport::Concern
  class_methods do
    def translate_property(name, options)
      # instead of one property, we define for each locale
      # property "#{name}", options
      I18n.available_locales.each do |locale|
        property "#{name}_#{locale}", options
      end

      define_method name do
        send "#{name}_#{I18n.locale}"
      end

      define_method "#{name}=" do |attr|
        send "#{name}_#{I18n.locale}=", attr
      end
    end
  end
end

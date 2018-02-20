namespace :translate do
  TRANSLATED_FIELDS = [{ klass: 'Location', properties: %i[name address] }].freeze
  desc 'find missing translations'
  task missing: :environment do
    TRANSLATED_FIELDS.each do |klass:, properties:|
      properties.each do |property|
        I18n.available_locales.each do |locale|
          klass.constantize.all.each do |item|
            method = "#{property}_#{locale}"
            next if item.send(method).present?
            puts "#{klass} method=#{method} id=#{item.id}"
          end
        end
      end
    end
  end

  desc 'copy translation from another'
  task copy: :environment do
    TRANSLATED_FIELDS.each do |klass:, properties:|
      klass.constantize.all.each do |item|
        properties.each do |property|
          I18n.available_locales.each do |locale|
            method = "#{property}_#{locale}"
            next if item.send(method).present?
            if locale == 'sr'
              if item.send("#{property}_en").present?
                item.send("#{method}=", item.send("#{property}_en").to_cyr)
                item.save!
              elsif item.send("#{property}_sr-latin").present?
                item.send("#{method}=", item.send("#{property}_sr-latin").to_cyr)
                item.save!
              end
            elsif locale == 'sr-latin'
              if item.send("#{property}_sr").present?
                item.send("#{method}=", item.send("#{property}_sr").to_lat)
                item.save!
              elsif item.send("#{property}_en").present?
                item.send("#{method}=", item.send("#{property}_en"))
                item.save!
              end
            elsif locale == 'en'
              if item.send("#{property}_sr").present?
                item.send("#{method}=", item.send("#{property}_sr").to_lat)
                item.save!
              elsif item.send("#{property}_sr-latin").present?
                item.send("#{method}=", item.send("#{property}_sr-latin"))
                item.save!
              end
            end
          end
        end
      end
    end
  end
end

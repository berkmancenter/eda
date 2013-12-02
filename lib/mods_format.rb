require 'oai'
module OAI::Provider::Metadata

  class MODS < Format
    def initialize
      @prefix = 'mods'
      @schema = 'http://www.loc.gov/standards/mods/v3/mods-3-4.xsd'
      @namespace = 'http://www.loc.gov/mods/v3'
      @element_namespace = nil
      @fields = [:identifier, :title, :url]
    end

    def header_specification
      {
        'xmlns' => "http://www.loc.gov/mods/v3" ,
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance" ,
        'xsi:schemaLocation' => "http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd"
      }
    end

    def encode(model, record)
      if record.respond_to?("to_#{prefix}")
        record.send("to_#{prefix}")
      else
        xml = Builder::XmlMarkup.new
        map = model.respond_to?("map_#{prefix}") ? model.send("map_#{prefix}") : {}
        xml.tag!(prefix, header_specification) do
          xml.tag! :titleInfo do
            xml.tag! :title, value_for(:title, record, map)
          end
          xml.tag! :location do
            xml.tag! :url, record.mods_full_image, :displayLabel => "Full Image"
            xml.tag! :url, record.mods_thumbnail, :displayLabel => "Thumbnail"
          end
          fields.each do |field|
            values = value_for(field, record, map)
            if values.respond_to?(:each)
              values.each do |value|
                xml.tag! field, value
              end
            else
              xml.tag! field, values
            end
          end
        end
        xml.target!
      end
    end
  end
end

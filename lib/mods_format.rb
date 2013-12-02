require 'oai'
module OAI::Provider::Metadata

  class MODS < Format
    def initialize
      @prefix = 'oai_mods'
      @schema = 'http://www.loc.gov/standards/mods/v3/mods-3-4.xsd'
      @namespace = 'http://www.loc.gov/mods/v3'
      @element_namespace = 'mods'
    end

    def header_specification
      {
        'xmlns' => "http://www.loc.gov/mods/v3" ,
        'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance" ,
        'xsi:schemaLocation' => "http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd"
      }
    end

  end

end

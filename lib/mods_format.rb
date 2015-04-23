require 'oai'
module OAI::Provider::Metadata

  class MODS < Format
    def initialize
      @prefix = 'mods'
      @schema = 'http://www.loc.gov/standards/mods/v3/mods-3-4.xsd'
      @namespace = 'http://www.loc.gov/mods/v3'
      @element_namespace = nil
    end

    def encode(model, record)
      if record.respond_to?("to_#{prefix}")
        record.send("to_#{prefix}")
      end
    end
  end
end

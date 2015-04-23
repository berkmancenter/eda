require 'spec_helper'

describe( 'oai requests' ) {
  subject { page }

  describe ( 'get /oai?verb=ListRecords&metadataPrefix=oai_dc' ) {
    before { visit "#{oai_repository_path}?verb=ListRecords&metadataPrefix=oai_dc" }

    it {
      status_code.should eq( 200 )
    }

    it {
      Hash.from_xml( source )[ 'OAI_PMH' ][ 'ListRecords' ].should_not eq( nil )
    }
  }
}

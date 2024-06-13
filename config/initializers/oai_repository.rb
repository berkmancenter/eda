Rails.application.config.to_prepare do
  if Sett.table_exists? && ActiveRecord::Base.connection.column_exists?(:setts, :ancestry)
    OaiRepository.setup do |config|
      config.repository_name = 'Emily Dickinson Archive'
  
      # The URL from which this OAI Repository is served.
      # If you're deploying to different hostnames (e.g. development, QA and
      # production environments, each with different hostnames), you could
      # dynamically set this.
      config.repository_url = 'http://www.edickinson.org/oai'
  
      # By default the (unique) identifier of each record will be composed as
      # #{record_prefix}/#{record.id}
      # This is probably not want you want, especially if you have multiple record
      # sets (i.e. this provider serves multiple ActiveRecord models)
      #
      # Most probably you'll create an oai_dc_identifier attribute or method in
      # the AR models you intend to serve. That value will supplant the default.
      config.record_prefix = 'http://www.edickinson.org'
  
      # This is your repository administrator's email address.
      # This will appear in the information returned from an "Identify" call to
      # your repository
      config.admin_email = 'jclark@cyber.law.harvard.edu'
  
      # The number of records shown at a time (when doing a ListRecords)
      config.limit = 100
  
      # The values for "models" should be the class name of the ActiveRecord model 
      # class that is being identified with the given set. It doesn't actually have
      # to be a ActiveRecord model class, but it should act like one.
      #
      # You must supply at least one model.
      config.models = [ Image ]
  
      # List the sets (and the ActiveRecord model they belong to). E.g.
      #
      # config.sets = [
      #   {
      #     spec: 'class:party',
      #     name: 'Parties',
      #     model: Person
      #   },
      #   {
      #     spec: 'class:service',
      #     name: 'Services',
      #     model: Instrument,
      #     description: 'Things that are services'
      #   }
      # ]
  
      config.sets = []
      Collection.roots.each do |c|
        next if c.name == 'Amherst College'
        config.sets << { spec: "collection:#{c.name.parameterize}", name: c.name, model: Image }
      end
  
      # By default, an OAI repository must emit its records in OAI_DC (Dublin Core)
      # format. If you want to provide other output formats for your repository
      # (and those formats are subclasses of OAI::Provider::Metadata.Format) then
      # you can specify them here. E.g.
      #
      # require 'rifcs_format'
      #
      # config.additional_formats = [
      #   OAI::Provider::Metadata::RIFCS
      # ]
      require 'MODS/format.rb'
      config.additional_formats = [OAI::Provider::Metadata::MODS]
    end
  end
end

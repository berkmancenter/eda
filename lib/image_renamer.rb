module ImageRenamer
    def new_filename(image)
        url = image.url
        case url[0..1]
        when 'ms'
            return url
        when 'as'
            pattern = /-\d{1,2}(-\d+)?$/
                id = image.metadata['Identifiers'].find{|i| i.starts_with?('Amherst Manuscript')}
            if url.match(pattern)
                new_name = "#{id.parameterize}#{url.match(pattern)[0]}"
            else 
                puts url
            end
            return new_name
        when '24'
            id = image.metadata['Identifier (BPL Ms. #)']
            new_name = id.parameterize + '-' + image.metadata['Accession No']
            return new_name
        else
            return nil
        end
    end
end

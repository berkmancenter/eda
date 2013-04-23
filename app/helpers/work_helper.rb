module WorkHelper
    def render_mod(mod = nil)
        return unless mod
        case mod.type
        when 'Emendation', 'Revision'
            render :partial => "shared/#{mod.type.downcase}", :locals => { :mod => mod }
        when 'Division'
            unless mod.subtype == 'author'
                render :partial => "shared/#{mod.subtype}_division", :locals => { :mod => mod }
            end
        when 'Alternate'
            render :partial => "shared/#{mod.subtype}", :locals => { :mod => mod }
        end
    end
end

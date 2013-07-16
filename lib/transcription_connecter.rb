require 'csv'
class TranscriptionConnecter
    COLUMN_NAME_TO_PREFIX_MAP = {
        :johnson => 'J',
        :franklin => 'F'
    }
    def connect(johnson_franklin_map)
        j_f_map = Hash[CSV.read(johnson_franklin_map, {:headers => true, :converters => :integer}).to_a[1..-1]]
        franklin = Edition.find_by_work_number_prefix('F')
        Edition.all.each do |edition|
            next unless COLUMN_NAME_TO_PREFIX_MAP.values.include?(edition.work_number_prefix) && edition != franklin
            edition.works.each do |work|
                next unless j_f_map.keys.include?(work.number)
                franklin_work = franklin.works.find_by_number(j_f_map[work.number])
                next unless franklin_work
                work_group = franklin_work.cross_edition_work_group
                work.cross_edition_work_group = work_group
                wgw = work_group.work_group_works.build
                wgw.work = work
                work.save!
                wgw.save!
                franklin_work.save!
            end
        end
    end
end
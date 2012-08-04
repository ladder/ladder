#
# Add a method to MARC::Record to export a Gyoku-compatible hash
# for converting to well-formed but possibly invalid MARCXML
#

class MARC::Record

  def to_gyoku_hash
    controlfields = []
    controlfield_tags = []
    datafields = []
    datafield_tags = []
    datafield_ind1 = []
    datafield_ind2 = []

    @fields.each do |field|
      if field.class == MARC::ControlField
        controlfield_tags << field.tag
        controlfields << field.value
      elsif field.class == MARC::DataField
        datafield_tags << field.tag
        datafield_ind1 << field.indicator1
        datafield_ind2 << field.indicator2

        subfields = []
        subfield_codes = []

        field.subfields.each do |subfield|
          subfields << subfield.value
          subfield_codes << subfield.code
        end

        datafields << { :subfield => subfields,
                        :attributes! => {
                          :subfield => {
                            :code => subfield_codes,
                           }
                        }
                      }
      end
    end

    { :record => {
        :leader => @leader,
        :controlfield => controlfields,
        :datafield => datafields,
        :attributes! => {
          :controlfield => {
            :tag => controlfield_tags },
          :datafield => {
            :tag => datafield_tags,
            :ind1 => datafield_ind1,
            :ind2 => datafield_ind2,
          },
        },
      },
      :attributes! => {
        :record => { :xmlns => 'http://www.loc.gov/MARC21/slim'},
      },
    }
  end
end
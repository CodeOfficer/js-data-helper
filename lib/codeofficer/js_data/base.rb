module CodeOfficer
  module JSData
    module Base
      
      def js_data_tag(dom_id, &block)
        @template.js_data_for JSDataBuilder.new(dom_id, &block)
      end
         
    end
  end
end
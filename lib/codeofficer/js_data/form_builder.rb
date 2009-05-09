module CodeOfficer
  module JSData
    module FormBuilder
      
      def js_data(&block)     
        @template.js_data_for JSDataBuilder.new(self, &block)
      end
      
    end
  end
end
module CodeOfficer
  module JSData


    def js_data_functions(framework, tag = :script)
      @js_data.to_s(framework, tag) unless @js_data.nil?
    end
    
    def js_data_for(data)
      (@js_data ||= JSDataCollection.new) << data
    end


    class JSDataCollection
      include Enumerable
    
      def initialize
        @data       = []
        @frameworks = [ :jquery, :prototype, :mootools ]
        @tags       = [ :ul, :pre, :script ]
      end
      
      def <<(data)
        @data << data
      end
      
      def each(&block)
        @data.each(&block)
      end

      def to_s(framework, tag)
        raise "Invalid framework" unless @frameworks.include? framework
        raise "Invalid tag" unless @tags.include? tag
        return self.send("to_#{tag}", framework)
      end
      
      private

      def to_script(framework)
       "<script type='text/javascript'>" << @data.collect{|x| x.send("to_#{framework}") }.join(" ") << "</script>"
      end
            
      def to_pre(framework)
       "<pre>\n" << @data.collect{|x| x.send("to_#{framework}") }.join("\n") << "\n</pre>"
      end
            
      def to_ul(framework)
       "<ul>\n" << collect { |x| "<li>" << x.send("to_#{framework}") << "</li>" }.join("\n") << "\n</ul>"
      end
    end
    

    class JSDataBuilder
      def initialize(dom, &block)
        raise ArgumentError, "Missing block" unless block_given?
        @label = 'railsData'
        @dom = dom
        @data_properties = {}
        yield self
      end
      
      def set(key, value)
        @data_properties.merge!({key => value})
      end
      
      def to_jquery
        "$('##{ dom_id }').data('#{ @label }', #{ js_object });"
      end
      
      def to_prototype
        "$('#{ dom_id }').store('#{ @label }', #{ js_object });"
      end
      
      def to_mootools
        "$('#{ dom_id }').store('#{ @label }', #{ js_object });"
      end

      private
        
      def js_object
        if @data_properties.empty?
          '{}'
        else
          "{#{ @data_properties.keys.map { |k| "#{k}:#{ formatted_value_property(@data_properties[k]) }" }.sort.join(', ') }}"
        end
      end
      
      def formatted_value_property(value)
        # TODO: decide a better way to test for functions?
        result = case value
          when /(\(|\))/: escape_function(value)
          when Fixnum: value
          when Float: value
          when true: "true"
          when false: "false"
          when "undefined": "undefined"
          when "NaN": "NaN"
          when nil: "null"
          when "null": "null"
          else "'#{value.strip}'" # its a string?
        end
      end
      
      def escape_function(string)
        string.strip!
        string.gsub!("\n", " ")
        string
      end

      def dom_id
        if @dom.is_a? String
          @dom
        else
          raise ArgumentError, "Missing Parameter: BUILDER" unless dom_is_a_builder?
          if builder_is_for_a_new_record?
            dom_id_for(@dom.object)
          else
            dom_id_for(@dom.object, :edit)
          end
        end
      end
      
      def dom_is_a_builder?
        @dom.kind_of? ActionView::Helpers::FormBuilder
      end
      
      def dom_id_for(obj, *args, &block)
        ActionController::RecordIdentifier.dom_id(obj, *args, &block)
      end
      
      def builder_is_for_a_new_record?
        @dom.object.respond_to?(:new_record?) && @dom.object.new_record?
      end
    end


  end
end
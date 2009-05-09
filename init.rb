require 'codeofficer/js_data'
require 'codeofficer/js_data/base'
require 'codeofficer/js_data/form_builder'

ActionView::Base.send :include, CodeOfficer::JSData
ActionView::Base.send :include, CodeOfficer::JSData::Base
ActionView::Helpers::FormBuilder.send :include, CodeOfficer::JSData::FormBuilder

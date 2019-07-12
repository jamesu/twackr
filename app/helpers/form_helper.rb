class FormBuilder
  def initialize(model)
    @model = model
  end

  def f_id(field)
    "#{@model.class.name.downcase}_#{field}"
  end

  def f_name(field)
    "#{@model.class.name.downcase}[#{field}]"
  end

  def mark_error(field, value)
    err = @model.errors.on(field)
    if !err.nil?
      return simple_tag(:div, value, :class => 'fieldWithErrors', :unescaped => true)
    else
      return value
    end
  end

  def attr_to_ts(list)
    list.map do |k,v| 
      if v.nil?
        if k == :selected
          "selected"
        else
          nil
        end
      else
        "#{k}=\"#{Rack::Utils.escape_html(v)}\""
      end
    end.compact.join(" ")
  end

  def simple_tag(type, content, attrs={})
    is_unescaped = attrs[:unescaped]
    attrs = attr_to_ts(attrs)
    if content.nil?
      "<#{type} #{attrs}/>"
    else
      if !is_unescaped
        content = Rack::Utils.escape_html(content)
      end
      "<#{type} #{attrs}>#{content}</#{type}>"
    end
  end

  def submit(label)
    simple_tag(:input, nil, :type => 'submit', :value => label)
  end

  def text_field(name)
    mark_error name, simple_tag(:input, nil,:id => f_id(name), :name => f_name(name), :type => 'text', :value => @model.send(name))
  end

  def select(name, options)
    model_value = @model.send(name)||0
    option_list = options.map do |opt|
      if model_value == opt[1].to_i
        simple_tag(:option, opt[0], :value => opt[1], :selected => nil)
      else
        simple_tag(:option, opt[0], :value => opt[1])
      end
    end.join('')

    mark_error name, simple_tag(:select, option_list, {:name => f_name(name), :unescaped => true})
  end

  def password_field(name)
    mark_error name, simple_tag(:input, nil, :id => f_id(name), :name => f_name(name), :type => 'password', :value => @model.send(name))
  end

  def label(field, desc, opts={})
    simple_tag(:label, desc, opts.merge({:for => field}))
  end
end

module FormHelper

  def error_messages_for(model)
    inst = instance_variable_get("@#{model}")
    return "" if inst.errors.count() == 0
    simple_tag(:div, 
      [
        simple_tag(:h2, t('errors.header', :num => inst.errors.count())),
        simple_tag(:p, ''),
        simple_tag(:ul, inst.errors.full_messages.map{|v|simple_tag(:li, v)}.join(''), :unescaped => true), 
      ].join(''),
      :id => 'errorExplanation', :unescaped => true)
  end

  def form_for(model, attrs={})
    actual_attrs = {}
    attrs[:method] ||= model.new? ? 'post' : 'put'
    actual_attrs[:action] = model.form_path

    input_method = nil
    if attrs.has_key?(:method) && attrs[:method] != 'get'
      actual_attrs[:method] = 'post'
      input_method = attrs[:method]
    end

    actual_attrs[:action] = attrs[:action] if attrs.has_key?(:action)
    actual_attrs[:'data-remote'] = '1' if attrs[:remote]

    output = capture_haml do
      haml_tag(:form, actual_attrs) do
        haml_tag(:input, {:type => 'hidden', :name => '_method', :value => input_method}) if !input_method.nil?
        yield(FormBuilder.new(model))
      end
    end

    output
  end

  def check_box_tag(name, value, checked, attrs={})
    new_attrs = attrs.merge({:type => 'checkbox', :name => name, :value => value||''})
    new_attrs[:checked] = true if checked
    capture_haml { haml_tag(:input, new_attrs) }
  end

  def text_field_tag(name, value, attrs)
    capture_haml { haml_tag(:input, attrs.merge(:type => 'text', :name => name, :value => value||'')) }
  end

  def select_tag(err)
    capture_haml { haml_tag(:input, :select) }
  end

  def password_field_tag(name, value, attrs)
    capture_haml { haml_tag(:input, attrs.merge(:name => name, :type => 'password', :value => value||'')) }
  end

end

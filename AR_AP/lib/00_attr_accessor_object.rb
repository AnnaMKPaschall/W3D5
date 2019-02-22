class AttrAccessorObject
  def self.my_attr_accessor(*names) 
    # ...
    names.each do |name| #iterate through given names to access
      define_method(name) {instance_variable_get("@#{name}") }  #define method on each name, call instance_variable_get on name for getter 
      define_method("#{name}=") {|val| instance_variable_set("@#{name}", val )}
    end
  end
end

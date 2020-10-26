class Object
  class << self
    def const_missing(c)
      return nil if @calling_const_missing     # 当调用const_missing方法中再次遇到未定义的常量时，我们不再递归地调用该方法而是返回一个nil
      @calling_const_missing = true
      require Rulers.to_underscore(c.to_s)
      klass = Object.const_get(c)
      @calling_const_missing = false
      klass
    end
  end
end
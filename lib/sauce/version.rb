module Sauce
  MAJOR_VERSION = '3.7'
  PATCH_VERSION = '2'

  def version
    "#{MAJOR_VERSION}.#{PATCH_VERSION}"
  end
  module_function :version
end

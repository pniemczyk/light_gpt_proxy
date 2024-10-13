# frozen_string_literal: true

module LightGptProxy
  module Templates
    Dir[File.join(__dir__, 'templates', '*.rb')].each do |file|
      filename = File.basename(file, '.rb')
      class_name = filename.split('_').collect(&:capitalize).join
      autoload class_name.to_sym, file
    end

    def self.template(name) = const_get("#{name.to_s.split('_').collect(&:capitalize).join}Template")

    def self.names
      @names ||= constants.map(&:to_s)
                          .select { |n| n.end_with?('Template') && n != 'Template' }
                          .map { |n| n.gsub(/Template\z/, '').gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase }.freeze
    end
  end
end

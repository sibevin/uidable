require 'uidable/version'

module Uidable
  DEFAULT_UID_SIZE = 32

  def self.included(base)
    base.extend ClassMethods
    unless defined?(::ActiveRecord::Base) && base < ::ActiveRecord::Base
      base.prepend InitUid
    end

    private

    def uidable_cols_init
      self.class.uidable_cols.each do |col|
        instance_variable_set("@#{col}", send("gen_#{col}"))
      end
    end
  end

  module InitUid
    def initialize
      uidable_cols_init
      super
    end
  end

  module ClassMethods
    def uidable(
        uid_name: 'uid',
        uid_size: DEFAULT_UID_SIZE,
        read_only: true,
        presence: true,
        uniqueness: :create,
        set_to_param: false,
        scope: false)
      unless uidable_cols.include?(uid_name.to_sym)
        uniqueness_check = case (uniqueness.to_sym)
                           when :create then "base.validates :'#{uid_name}', uniqueness: true, on: :create"
                           when :always then "base.validates :'#{uid_name}', uniqueness: true"
                           else ''
        end
        uidable_cols << uid_name.to_sym
        mod = Module.new
        mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.included(base)
            if defined?(::ActiveRecord::Base) && base < ::ActiveRecord::Base
              base.before_validation :uidable_assign_#{uid_name}, on: :create
              #{scope ? "base.scope :'with_#{uid_name}', -> (uid) { base.where(:'#{uid_name}' => uid) }" : ''}
              #{set_to_param ? "base.include SetToParam#{uid_name}" : ''}
              #{read_only ? "base.attr_readonly :'#{uid_name}'" : ''}
            else
              #{read_only ? "attr_reader :'#{uid_name}'" : "attr_accessor :'#{uid_name}'"}
            end
            if base.respond_to?(:validates)
              #{presence ? "base.validates :'#{uid_name}', presence: true" : ''}
              #{uniqueness_check}
            end
          end

          module SetToParam#{uid_name}
            def to_param
              self.#{uid_name}
            end
          end

          private

          def uidable_assign_#{uid_name}
            self.#{uid_name} = gen_#{uid_name}
          end

          def gen_#{uid_name}
            Array.new(#{uid_size}){[*'a'..'z', *'0'..'9'].sample}.join
          end
        RUBY
        include mod
      end
    end

    def uidable_cols
      @uidable_cols ||= []
    end
  end
end

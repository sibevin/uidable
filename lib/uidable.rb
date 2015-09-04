require "uidable/version"

module Uidable
  DEFAULT_UID_SIZE = 32

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def uidable(
        uid_name: "uid",
        uid_size: DEFAULT_UID_SIZE,
        read_only: true,
        presence: true,
        uniqueness: true,
        set_to_param: false,
        scope: false)
      mod = Module.new
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.included(base)
          if defined?(::ActiveRecord::Base) && base < ::ActiveRecord::Base
            base.before_validation :assign_uid, on: :create
            #{ scope ? "base.scope :'with_#{uid_name}', -> (uid) { base.where(:'#{uid_name}' => uid) }" : "" }
            #{ set_to_param ? "base.include SetToParam" : "" }
            #{ read_only ? "base.attr_readonly :'#{uid_name}'" : "" }
          else
            base.prepend InitUid
            #{ read_only ? "attr_reader :'#{uid_name}'" : "attr_accessor :'#{uid_name}'" }
          end
          if base.respond_to?(:validates)
            #{ presence ? "base.validates :'#{uid_name}', presence: true" : "" }
            #{ uniqueness ? "base.validates :'#{uid_name}', uniqueness: true" : "" }
          end
        end

        module InitUid
          def initialize
            @#{uid_name} = gen_uid
            super
          end
        end

        module SetToParam
          def to_param
            self.#{uid_name}
          end
        end

        private

        def assign_uid
          self.#{uid_name} = gen_uid
        end

        def gen_uid
          Array.new(#{uid_size}){[*'a'..'b', *'0'..'9'].sample}.join
        end
      RUBY
      include mod
    end
  end
end

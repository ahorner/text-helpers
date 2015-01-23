require 'minitest/autorun'
require File.expand_path('../../lib/text_helpers.rb', __FILE__)

module StubHelpers

  # Public: Stub a constant down a nested module path.
  #
  # target      - A target Class or Module to stub a constant on.
  # module_path - A path to a constant, like "Foo::Bar::Baz".
  # stub        - The stub value to return.
  #
  # Yields a block during which the stub is in place.
  # Returns a Proc that can be called to reset the stub, if no block was given.
  def stub_nested_const(target, module_path, stub)
    module_names = module_path.split("::")[0..-1]

    # Save original values
    _, *original_values = module_names.inject([target]) do |collected, module_name|
      last_module = collected.last
      break(collected) unless last_module.const_defined?(module_name, false)

      collected.push(last_module.const_get(module_name, false))
    end

    # Stub new values
    *chain, last = module_names

    last_stubbed = chain.inject(target) do |t, module_name|
      module_value = if t.const_defined?(module_name, false)
                       t.const_get(module_name, false)
                     else
                       Module.new
                     end

      t.const_set(module_name, module_value)
    end

    last_stubbed.const_set(last, stub)

    # Reset values
    reset_block = lambda do
      unset_last = original_values.length != module_names.length

      last_target = original_values.zip(module_names).inject(target) do |t, (value, name)|
        t.const_set(name, value)
      end

      if unset_last
        last_target.send(:remove_const, module_names[original_values.length])
      end
    end

    block_given? ? yield : reset_block
  ensure
    reset_block.call if block_given?
  end
end

I18n.enforce_available_locales = false

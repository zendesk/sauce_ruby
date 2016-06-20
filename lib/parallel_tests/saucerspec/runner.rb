require "yaml"
require "parallel_tests/rspec/runner"
require "sauce/logging"

module ParallelTests
  module Saucerspec
    class Runner < ParallelTests::RSpec::Runner

      def self.run_tests(test_files, process_number, num_processes, options)
        our_options = options.dup
        exe = executable # expensive, so we cache
        version = (exe =~ /\brspec\b/ ? 2 : 1)
        cmd = [exe, our_options[:test_options], (rspec_2_color if version == 2), spec_opts, *test_files].compact.join(" ")
        env = Sauce::TestBroker.next_environment(test_files)
        env << " #{rspec_1_color}" if version == 1
        our_options.merge!(:env => env)
        Sauce.logger.debug "Starting parallel process #{process_number} of #{num_processes}"
        Sauce.logger.debug "  #{cmd}"
        Sauce.logger.debug "  #{our_options}"
        execute_command(cmd, process_number, num_processes, our_options)
      end


      def self.tests_in_groups(tests, num_groups, options={})
        _tests_in_groups = super
        test_platforms = Sauce::TestBroker.test_platforms(:rspec)
        # ignore groupping by runtime/size from super when we need to run tests against several platforms (cross-browser)
        if test_platforms.length > 1
          all_tests = _tests_in_groups.flatten * test_platforms.length
          base_group_size = all_tests.length / num_groups
          num_full_groups = all_tests.length - (base_group_size * num_groups)

          curpos = 0
          groups = []
          num_groups.times do |i|
            group_size = base_group_size
            if i < num_full_groups
              group_size += 1
            end
            groups << all_tests.slice(curpos, group_size)
            curpos += group_size
          end
          groups
        else
          _tests_in_groups
        end
      end
    end
  end
end

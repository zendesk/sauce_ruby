module ParallelTests
  class CLI
    def run_tests_in_parallel(num_processes, options)
      test_results = nil

      report_time_taken do
        groups = @runner.tests_in_groups(options[:files], num_processes, options)

        groups.reject! &:empty?
        Sauce::TestBroker.test_groups = groups

        test_results = if options[:only_group]
          groups_to_run = options[:only_group].collect{|i| groups[i - 1]}.compact
          report_number_of_tests(groups_to_run)
          execute_in_parallel(groups_to_run, groups_to_run.size, options) do |group|
            run_tests(group, Sauce::TestBroker.group_index(group), 1, options)
          end
        else
          report_number_of_tests(groups)
          execute_in_parallel(groups, groups.size, options) do |group|
            run_tests(group, Sauce::TestBroker.group_index(group), num_processes, options)
          end
        end

        Sauce.logger.debug "Parallel Tests reporting results."
        report_results(test_results, options)
      end

      abort final_fail_message if any_test_failed?(test_results)
    end
  end
end
# frozen_string_literal: true

require_relative 'skill'
require_relative 'job'

module  Views
  # A view object that holds all data about Skillset
  class SkillJob
    def initialize(jobs, skills)
      @jobs = jobs
      @skills = skills
      @skillset = nil
    end

    def skillset
      analyze_skillset
      @skillset
    end

    def jobs
      @jobs.map { |job| Views::Job.new(job) }
    end

    def max_salary
      analyze_skillset
      @skillset.max_by(&:max_salary)
               .max_salary_str
    end

    def min_salary
      analyze_skillset
      @skillset.min_by(&:min_salary)
               .min_salary_str
    end

    # UTILITIES

    def analyze_skillset
      return if @skillset

      skill_count = @skills.group_by(&:name)
                           .transform_values!(&:length)
      sorted_skill = skill_count.sort_by { |_, count| count }
                                .reverse!
      @skillset = sorted_skill.map do |name, count|
        first_skill = @skills.find { |skill| skill.name == name }
        Views::Skill.new(first_skill, count)
      end
    end
  end
end

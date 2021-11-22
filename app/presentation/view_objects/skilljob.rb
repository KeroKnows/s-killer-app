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

      sorted_skill = skill_count.sort_by { |_, count| count }
                                .reverse!
      @skillset = transform_to_entity(sorted_skill)
    end

    def skill_count
      skill_group = @skills.group_by(&:name)
      skill_group.transform_values(&:length)
    end

    def transform_to_entity(sorted_skill)
      sorted_skill.map do |name, count|
        first_skill = find_first(name)
        Views::Skill.new(first_skill, count)
      end
    end

    def find_first(name)
      @skills.find { |skill| skill.name == name }
    end
  end
end

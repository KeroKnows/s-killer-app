# frozen_string_literal: true

require_relative 'skill'
require_relative 'job'

module  Views
  # A view object that holds all data about Skillset
  class SkillJob
    attr_reader :query

    def initialize(query, jobs, skills, salary_distribution)
      @query = query
      @jobs = jobs
      @skills = skills
      @salary_distribution = salary_distribution
      @skillset = nil
    end

    def skills
      analyze_skillset
      @skillset
    end

    def jobs
      @jobs.map { |job| Views::Job.new(job) }
    end

    def max_salary
      maximum = @salary_distribution.maximum
      maximum = maximum ? maximum.to_i : Float::INFINITY
      return 'None' if maximum.infinite?

      "#{@salary_distribution.currency}$ #{maximum}"
    end

    def min_salary
      minimum = @salary_distribution.minimum
      minimum = minimum ? minimum.to_i : -Float::INFINITY
      return 'None' if minimum.infinite?

      "#{@salary_distribution.currency}$ #{minimum}"
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

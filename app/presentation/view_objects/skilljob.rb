#frozen_string_literal: true

require_relative 'skill'
require_relative 'job'

module  Views
  # View object for Skillset
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

    def skills
      analyze_skillset
      @skillset.map { |skill, _| skill }
    end

    def jobs
      @jobs.map { |job| Views::Jobs.new(job) }
    end

    def max_salary
      analyze_skillset
      @skillset.max_by { |skill| skill.max_salary }
               .max_salary
    end

    def min_salary
      analyze_skillset
      @skillset.min_by { |skill| skill.min_salary }
               .min_salary
    end

    # UTILITIES

    def analyze_skillset
      return if @skillset

      skill_count = @skills.group_by(&:name)
                           .transform_values!(&:length)
      sorted_skill = skill_count.sort_by { |_, count| count }
                                .reverse!
      @skillset = sorted_skill.map do |name, count| 
        skill = @skills.find { |skill| skill.name == name }
        Views::Skill.new(skill, count)
      end
    end
  end
end
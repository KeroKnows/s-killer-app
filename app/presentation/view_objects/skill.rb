#frozen_string_literal: true

module Views
  class Skill
    def initialize(skill, count)
      @skill = skill
      @count = count
    end

    def name
      @skill.name
    end

    def max_salary
      @skill.salary.year_max || -Float::INFINITY
    end

    def min_salary
      @skill.salary.year_min || Float::INFINITY
    end

    def currency
      @skill.salary.currency
    end

    def count
      @count
    end

    def jobs
      # [ TODO ] Get jobs relating to this skill
    end
  end
end
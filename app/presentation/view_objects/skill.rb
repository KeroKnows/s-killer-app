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

    def max_salary_str
      return "None" if max_salary.infinite?
      "#{currency}$ #{max_salary}"
    end

    def min_salary_str
      return "None" if min_salary.infinite?
      "#{currency}$ #{min_salary}"
    end

    def max_salary
      salary = @skill.salary.year_max
      salary ? salary.to_i : -Float::INFINITY
    end

    def min_salary
      salary = @skill.salary.year_min
      salary ? salary.to_i : Float::INFINITY
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
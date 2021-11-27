# frozen_string_literal: true

module Views
  # A view object that holds all data about skill
  class Skill
    attr_reader :count

    def initialize(skill, count)
      @skill = skill
      @count = count
    end

    def name
      @skill.name
    end

    def jobs
      # [ TODO ] Get jobs relating to this skill
    end
  end
end

# frozen_string_literal: true

require_relative '../../helpers/vcr_helper'

describe 'Test View Objects' do
  describe 'Test Job Object' do
    before do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      @job = Skiller::Entity::Job.new(db_id: nil,
                                      job_id: 0,
                                      title: 'JOB TITLE',
                                      description: '<h1>JOB TITLE</h1><p>description</p>',
                                      location: 'LOCATION',
                                      salary: salary,
                                      url: 'URL',
                                      is_full: true)
      @job_object = Views::Job.new(@job)
    end

    it 'HAPPY: should extract properties properly' do
      _(@job_object.title).must_equal @job.title
      _(@job_object.location).must_equal @job.location
    end

    it 'HAPPY: should parse description to pure text' do
      _(@job_object.description).wont_match %r{</?\w+>}
    end

    it 'HAPPY: should be able to provide the brief description' do
      _(@job_object.brief.length).must_be :<, 305
    end
  end

  describe 'Test Skill Object' do
    it 'HAPPY: should extract properties properly' do
      skill = Skiller::Entity::Skill.new(id: nil,
                                         job_db_id: nil,
                                         name: 'Python',
                                         salary: nil)
      count = 10
      skill_object = Views::Skill.new(skill, count)
      _(skill_object.name).must_equal skill.name
      _(skill_object.count).must_equal count
    end

    it 'HAPPY: should not return nil with salary' do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      skill = Skiller::Entity::Skill.new(id: nil,
                                         job_db_id: nil,
                                         name: 'Python',
                                         salary: salary)
      skill_object = Views::Skill.new(skill, 0)
      _(skill_object.min_salary).wont_be_nil
      _(skill_object.max_salary).wont_be_nil
    end

    it 'HAPPY: should transform salary to string' do
      currency = 'USD'
      min_salary = 10.0
      max_salary = 10_000.0
      salary = Skiller::Value::Salary.new(year_min: min_salary,
                                          year_max: max_salary,
                                          currency: currency)
      skill = Skiller::Entity::Skill.new(id: nil,
                                         job_db_id: nil,
                                         name: 'Python',
                                         salary: salary)
      skill_object = Views::Skill.new(skill, 0)
      _(skill_object.min_salary_str).must_equal "#{currency}$ #{min_salary.to_i}"
      _(skill_object.max_salary_str).must_equal "#{currency}$ #{max_salary.to_i}"

      nil_salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      nil_skill = Skiller::Entity::Skill.new(id: nil,
                                             job_db_id: nil,
                                             name: 'Python',
                                             salary: nil_salary)
      nil_skill_object = Views::Skill.new(nil_skill, 0)
      _(nil_skill_object.min_salary_str).must_equal 'None'
      _(nil_skill_object.max_salary_str).must_equal 'None'
    end

    it 'HAPPY: should return the relating jobs' do
      skip 'NOT IMPLEMENTED'
    end
  end

  describe 'Test SkillJob Object' do
    it 'HAPPY: should extract the skillset as skill object' do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      skills = [
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'AWS', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'Python', salary: salary)
      ]
      skilljob = Views::SkillJob.new(nil, skills)
      skilljob.skillset.each do |skill|
        _(skill).must_be_instance_of Views::Skill
      end
    end

    it 'HAPPY: should sort the skillset by count' do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      skills = [
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'AWS', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'Python', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'AWS', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'Python', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'JavaScript', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'Python', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'JavaScript', salary: salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'JavaScript', salary: salary)
      ]
      skilljob = Views::SkillJob.new(nil, skills)
      count = skilljob.skillset.map(&:count)
      _(count).must_equal count.sort.reverse!
    end

    it 'HAPPY: should return the job object' do
      salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      jobs = [Skiller::Entity::Job.new(db_id: nil,
                                       job_id: 0,
                                       title: 'JOB1 TITLE',
                                       description: '<h1>JOB1 TITLE</h1><p>description</p>',
                                       location: 'LOCATION',
                                       salary: salary,
                                       url: 'URL',
                                       is_full: true),
              Skiller::Entity::Job.new(db_id: nil,
                                       job_id: 1,
                                       title: 'JOB2 TITLE',
                                       description: '<h1>JOB2 TITLE</h1><p>description</p>',
                                       location: 'LOCATION',
                                       salary: salary,
                                       url: 'URL',
                                       is_full: true)]

      skilljob = Views::SkillJob.new(jobs, nil)
      skilljob.jobs.each do |job|
        _(job).must_be_instance_of Views::Job
      end
    end

    it 'HAPPY: should correctly calculate the max/min salary' do
      max_salary = Skiller::Value::Salary.new(year_min: 10.0, year_max: 1000.0, currency: 'USD')
      min_salary = Skiller::Value::Salary.new(year_min: 1.0, year_max: 100.0, currency: 'USD')
      nil_salary = Skiller::Value::Salary.new(year_min: nil, year_max: nil, currency: nil)
      skills = [
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'Ruby', salary: max_salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'JavaScript', salary: min_salary),
        Skiller::Entity::Skill.new(id: nil, job_db_id: nil, name: 'Python', salary: nil_salary)
      ]
      max_salary_skill = Views::Skill.new(skills[0], 0)
      min_salary_skill = Views::Skill.new(skills[1], 0)
      skilljob = Views::SkillJob.new(nil, skills)
      _(skilljob.max_salary).must_equal max_salary_skill.max_salary_str
      _(skilljob.min_salary).must_equal min_salary_skill.min_salary_str
    end
  end
end

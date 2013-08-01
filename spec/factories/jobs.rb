require 'factory_girl'

FactoryGirl.define do
  factory :import_schedule do
    start_datetime Time.current
    end_date Time.current + 1.year
    frequency 'monthly'
    truncate false
    new_table true
    sample_count 1
    association :workspace
    association :user
    sequence(:to_table) { |n| "factoried_import_schedule_table#{n}" }
    association :source_dataset, factory: :gpdb_table
  end

  factory :abstract_import, class: Import do
    created_at Time.current
    user
    sequence(:to_table) { |n| "factoried_import_table#{n}" }
    truncate false
    new_table true
    sample_count 10
    file_name nil

    factory :import, class: WorkspaceImport do
      association :workspace, factory: :workspace_with_sandbox
      association :source, factory: :gpdb_table

      after(:build) { |import| import.class.skip_callback(:validate) }
    end

    factory :schema_import, class: SchemaImport do
      association :schema, factory: :gpdb_schema
      association :source, factory: :gpdb_table
    end
  end

  factory :import_with_schedule, parent: :import do
    association :import_schedule
  end

  factory :csv_file do
    workspace
    user
    truncate false
    to_table 'some_new_table'
    column_names ['id', 'body']
    types ['text', 'text']
    delimiter ','
    has_header true
    contents { Rack::Test::UploadedFile.new(File.expand_path("spec/fixtures/test.csv", Rails.root), "text/csv") }
  end

  factory :csv_import do
    created_at Time.current
    workspace
    association :destination_dataset, factory: :gpdb_table
    user
    csv_file
    sequence(:to_table) { |n| "factoried_import_table#{n}" }
    truncate false
    new_table true
  end

  factory :gnip_import do
    created_at Time.current
    workspace
    user
    sequence(:to_table) { |n| "factoried_import_table#{n}" }
    truncate false
    new_table true
    association :source, :factory => :gnip_data_source
  end

  factory :job do
    name { Faker::Company.bs.titlecase }
    association :workspace
    next_run 2.days.from_now
    end_run 3.days.from_now
    time_zone 'Alaska'
    interval_unit { %w( hours days weeks months ).sample }
    interval_value { rand(100)+1 }
  end

  factory :job_task do
    name { Faker::Company.bs.titlecase }
    sequence(:index) { |n| n }
    job
    action { %w( import_source_data run_work_flow run_sql_file ).sample }
  end

  factory :import_source_data_task do
    sequence(:index) { |n| 100 + n }
    job
    action { 'import_source_data' }
    source_id Dataset.first.id
    destination_id Dataset.last.id
    destination_name nil
    truncate false
    row_limit 500
  end
end
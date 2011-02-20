ActiveRecord::Schema.define do
  create_table "courses", :force => true do |t|
    t.string   "title"
    t.string   "course_key"
    t.text     "description"
    t.float    "points"
    t.datetime "updated_at"
  end

  create_table "departments", :force => true do |t|
    t.string "abbreviation"
    t.string "title"
  end

  create_table "instructors", :force => true do |t|
    t.string "name"
  end

  create_table "schools", :force => true do |t|
    t.string "abbreviation"
    t.string "name"
  end

  create_table "sections", :force => true do |t|
    t.string  "title"
    t.integer "call_number"
    t.text    "description"
    t.string  "days"
    t.float   "start_time"
    t.float   "end_time"
    t.string  "room"
    t.string  "building"
    t.integer "instructor_id"
    t.integer "department_id"
    t.integer "subject_id"
    t.integer "section_number"
    t.string  "section_key"
    t.integer "course_id"
    t.string  "semester"
    t.string  "url"
    t.integer "enrollment"
    t.integer "max_enrollment"
  end

  create_table "subjects", :force => true do |t|
    t.string "abbreviation"
    t.string "title"
  end

end
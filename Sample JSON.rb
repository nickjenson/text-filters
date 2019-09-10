#!/usr/bin/env ruby
require 'json'

file_contents = ARGF.read
filter_enrollments = false
filter_duplicate_enrollments = false
max_student_enrollments = 2
max_sections = 2


rand_one = (rand() * 100).to_i #random number in array to generate course_id TODO: grab section that has an enrollment instead of random
rand_two = (rand() * 100).to_i #random number in array to generate course_id


data = JSON.parse(file_contents)
course_id_1 = data['courses'][rand_one]['course_id']
course_id_2 = data['courses'][rand_two]['course_id']
course_list = ["#{course_id_1}", "#{course_id_2}"]
outdata = {"settings"=>[],"accounts"=>[],"courses"=>[],"enrollments"=>[],"sections"=>[],"terms"=>data['terms'],"users"=>[]}
section_list = []
user_list = []
enr_user_list = []
enr_temp = []
enr_list = []
student_enrollment_count = {}
section_count = {}
account_list = []

#courses
data['courses'].each do |course|
    if(course_list.include?(course['course_id']))
        # puts course
        outdata['courses'].push(course)
        section_count[course['course_id']] = 1
    end
end

#sections
data['sections'].each do |section|
    if(course_list.include?(section['course_id']))
        outdata['sections'].push(section)
        section_list.push(section['section_id'])
        account_list.push(section['sis_account_id']) unless account_list.include?(section['sis_account_id'])
        student_enrollment_count[section['section_id']] = 0
        section_count[section['course_id']] += 1
        break if section_count[section['course_id']] > max_sections
    end
end

#accounts
data['accounts'].each do |account|
    outdata['accounts'].push(account) if(account_list.include?(account['_original']['sourcedId']))
end

#enrollments
data['enrollments'].each do |enrollment|
    if(section_list.include?(enrollment['section_id']) && (!filter_duplicate_enrollments || !enr_list.include?("#{enrollment['user_id']}~#{enrollment['section_id']}")) && (enrollment['role'].downcase == 'teacher' || student_enrollment_count[enrollment['section_id']] < max_student_enrollments))
        student_enrollment_count[enrollment['section_id']] += 1 if enrollment['role'].downcase == 'student'
        enr_temp.push(enrollment)
        enr_user_list.push(enrollment['user_id'])
        enr_list.push("#{enrollment['user_id']}~#{enrollment['section_id']}")
    end
end

#users
data['users'].each do |user|
    if(enr_user_list.include?(user['user_id']) && !user_list.include?(user['user_id']))
        outdata['users'].push(user)
        user_list.push(user['user_id'])
    end
end

#filter enrollments
if filter_enrollments
    enr_temp.each do |enrollment|
        if(user_list.include?(enrollment['user_id']))
            outdata['enrollments'].push(enrollment)
        end
    end
else
    outdata['enrollments'] = enr_temp
end

response = {"course_list": {"course_id_1": "#{course_id_1}","course_id_2": "#{course_id_2}"},"filter_enrollments": "#{filter_enrollments}","filter_duplicate_enrollments": "#{filter_duplicate_enrollments}","max_student_enrollments": "#{max_student_enrollments}","max_sections": "#{max_sections}","counts": {"accounts": "#{outdata['accounts'].length}","courses": "#{outdata['courses'].length}","enrollments": "#{outdata['enrollments'].length}","sections": "#{outdata['sections'].length}","terms": "#{data['terms'].length}","users": "#{outdata['users'].length}"}}
outdata['settings'].push(response)

print JSON.pretty_generate(outdata)
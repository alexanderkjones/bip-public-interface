# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

@neo = Neography::Rest.new

query = "CREATE (root {name: 'root'})," +
"(user1 { name: 'Alex'})," +
"(user2 { name: 'Anthony' })," +
"(user3 { name: 'Dennis' })," +
"(user4 { name: 'Karen' })," +

"(hiveloss1 { name: 'hive_loss', value: 10 })," +
"(hiveloss2 { name: 'hive_loss', value: 25 })," +
"(hiveloss3 { name: 'hive_loss', value: 30 })," +
"(hiveloss4 { name: 'hive_loss', value: 45 })," +

"(apivar { name: 'Apivar'})," + 
"(checkmite { name: 'CheckMite+'})," +

"(february { name: 'February' })," +
"(april { name: 'April' })," +
"(june { name: 'June'})," +
"(august { name: 'August' })," +
"(october { name: 'October' })," +

"(schedule_a { name: 'schedule_a', num_treatments: 4, num_products: 1 })," +
"(schedule_a)-[:APPLIED] ->(at1)," +
"(schedule_a)-[:APPLIED] ->(at2)," +
"(schedule_a)-[:APPLIED] ->(at3)," +
"(schedule_a)-[:APPLIED] ->(at4)," +

"(at1)-[:PRODUCT_USED]->(apivar)," +
"(at2)-[:PRODUCT_USED]->(apivar)," +
"(at3)-[:PRODUCT_USED]->(apivar)," +
"(at4)-[:PRODUCT_USED]->(apivar)," +

"(at1)-[:DATE_APPLIED]->(april)," +
"(at2)-[:DATE_APPLIED]->(june)," +
"(at3)-[:DATE_APPLIED]->(august)," +
"(at4)-[:DATE_APPLIED]->(october)," +

"(schedule_b { name: 'schedule_b', num_treatments: 3, num_products: 2})," +
"(schedule_b)-[:APPLIED] ->(bt1)," +
"(schedule_b)-[:APPLIED] ->(bt2)," +
"(schedule_b)-[:APPLIED] ->(bt3)," +

"(bt1)-[:PRODUCT_USED]->(checkmite)," +
"(bt2)-[:PRODUCT_USED]->(apivar)," +
"(bt3)-[:PRODUCT_USED]->(apivar)," +

"(bt1)-[:DATE_APPLIED]->(february)," +
"(bt2)-[:DATE_APPLIED]->(june)," +
"(bt3)-[:DATE_APPLIED]->(august)," +

"(schedule_c { name: 'schedule_c', num_treatments: 2, num_products: 1})," +
"(schedule_c)-[:APPLIED] ->(ct1)," +
"(schedule_c)-[:APPLIED] ->(ct2)," +

"(ct1)-[:PRODUCT_USED]->(apivar)," +
"(ct2)-[:PRODUCT_USED]->(apivar)," +

"(ct1)-[:DATE_APPLIED]->(april)," +
"(ct2)-[:DATE_APPLIED]->(june)," +

"(schedule_d { name: 'schedule_b', num_treatments: 3, num_products: 1})," +
"(schedule_d)-[:APPLIED] ->(dt1)," +
"(schedule_d)-[:APPLIED] ->(dt2)," +
"(schedule_d)-[:APPLIED] ->(dt3)," +

"(dt1)-[:PRODUCT_USED]->(apivar)," +
"(dt2)-[:PRODUCT_USED]->(apivar)," +
"(dt3)-[:PRODUCT_USED]->(apivar)," +

"(dt1)-[:DATE_APPLIED]->(april)," +
"(dt2)-[:DATE_APPLIED]->(june)," +
"(dt3)-[:DATE_APPLIED]->(august)," +

"(user1)-[:REPORTED]->(hiveloss1)," +
"(user2)-[:REPORTED]->(hiveloss2)," +
"(user3)-[:REPORTED]->(hiveloss3)," +
"(user4)-[:REPORTED]->(hiveloss4)," +

"(user1)-[:USED]->(schedule_a)," +
"(user2)-[:USED]->(schedule_b)," +
"(user3)-[:USED]->(schedule_c)," +
"(user4)-[:USED]->(schedule_d)," +

"(user1)-[:IS_IN]->(root)," +
"(user2)-[:IS_IN]->(root)," +
"(user3)-[:IS_IN]->(root)," +
"(user4)-[:IS_IN]->(root)"

@neo.execute_query(query)

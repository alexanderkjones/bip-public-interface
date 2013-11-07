class HomeController < ApplicationController
  def index
    @neo = Neography::Rest.new
    @the_months = @neo.execute_query("START n=node:Months('*:*') RETURN n")["data"]
    @months = []
    @the_months.each do |m|
      @months.push(Neography::Node.load(m.first["self"]))
    end

    @the_products = @neo.execute_query("START n=node:Products('*:*') RETURN n")["data"]    
    @products = []
    @the_products.each do |t|
      @products.push(Neography::Node.load(t.first["self"]))
    end
  end

  def results
    @neo = Neography::Rest.new

    products = []
    months = []
    params[:plans].each do |k, v|
      v.each do |l, w|
        if l != "" && w != ""
          products.push(l)
          months.push(w)
        end
      end
    end

    query_start = "START "
    (0..products.length-1).each do |t|
      unless query_start.include?("#{products[t].downcase}=node:Products('name:#{products[t]}'), ")
        query_start += "#{products[t].downcase}=node:Products('name:#{products[t]}'), "
      end
      
      unless query_start.include?("#{months[t].downcase}=node:Months('name:#{months[t]}'), ")
        query_start += "#{months[t].downcase}=node:Months('name:#{months[t]}'), "
      end
    end
    query_start = query_start[0..-3]

    query_match = "MATCH "
    (0..products.length-1).each do |t|
      unless query_match.include?("(schedule) - [:APPLIED] -> (t#{t+1}) - [:PRODUCT_USED] -> (#{products[t].downcase}), ")
        query_match += "(schedule) - [:APPLIED] -> (t#{t+1}) - [:PRODUCT_USED] -> (#{products[t].downcase}), "
      end
    end
    
    (0..products.length-1).each do |t|
      unless query_match.include?("(t#{t+1}) - [:DATE_APPLIED] -> (#{months[t].downcase}), ")
        query_match += "(t#{t+1}) - [:DATE_APPLIED] -> (#{months[t].downcase}), "
      end
    end
    query_match = query_match[0..-3]
    
    query_where = "WHERE (schedule.num_products = #{products.uniq.count}) AND (schedule.num_treatments = #{products.count}) "
    query_with_distinct = "WITH DISTINCT schedule "
    query_match2 = "MATCH (hiveloss) <- [:REPORTED] - (user) - [:USED] -> (schedule) "
    query_return = "RETURN user as user, hiveloss as hive_loss"

    query = query_start + query_match + query_where + query_with_distinct + query_match2 + query_return
    
    @loss = @neo.execute_query(query)
    
    respond_to do |format|
      format.js { render partial: "results"}
#      format.json { render json: {}, status: :ok }
    end
  end
  
  def query
    @neo = Neography::Rest.new
    
    query_1 = "START apivar=node(10), april=node:Months('name:April'), june=node(14), august=node(15) " +
            "MATCH (schedule) - [:APPLIED] -> (t1) - [:PRODUCT_USED] -> (apivar), " +
            "(schedule) - [:APPLIED] -> (t2) - [:PRODUCT_USED] -> (apivar), " +
            "(schedule) - [:APPLIED] -> (t3) - [:PRODUCT_USED] -> (apivar), " +
            "(t1) - [:DATE_APPLIED] -> (april), " +
            "(t2) - [:DATE_APPLIED] -> (june), " +
            "(t3) - [:DATE_APPLIED] -> (august) " +
            "WHERE (schedule.num_products=1) AND (schedule.num_treatments=3) " +
            "WITH DISTINCT schedule " +
            "MATCH (hiveloss) <- [:REPORTED] - (user) - [:USED] -> (schedule) " +
            "RETURN user as user"
            
    @query1 = @neo.execute_query(query_1)["data"]    
    @query1_results = []
    
    for i in 0..@query1.length-1
      @query1_results.push(@query1[i].first["data"]["name"]) unless @query1_results.include?(@query1[i].first["data"]["name"])
    end

    query_2 = "START apivar=node(10)" +
              "MATCH (schedule) - [:APPLIED] -> (t) - [:PRODUCT_USED] -> (apivar)" +
              "WHERE (schedule.num_products=1)" +
              "WITH DISTINCT schedule " +
              "MATCH (hiveloss) <- [:REPORTED] - (user) - [:USED] -> (schedule) " +
              "RETURN schedule as schedule, user as user, hiveloss as hive_loss"
              
    @query2 = @neo.execute_query(query_2)["data"]
    @query2_results = []
    
    for i in 0..@query2.length-1
      @query2_results.push(@query2[i].first["data"]) unless @query2_results.include?(@query2[i].first["data"])
    end
    
    query_3 = "START apivar=node(10), april=node(13), june=node(14), august=node(15) " +
              "MATCH (schedule) - [:APPLIED] -> (t1) - [:DATE_APPLIED] -> (april), " +
              "(schedule) - [:APPLIED] -> (t2) - [:DATE_APPLIED] -> (june), " +
              "(schedule) - [:APPLIED] -> (t3) - [:DATE_APPLIED] -> (august) " +
              "WHERE (schedule.num_treatments=3) " +
              "WITH DISTINCT schedule " +
              "MATCH (hiveloss) <- [:REPORTED] - (user) - [:USED] -> (schedule) " +
              "RETURN schedule as schedule, user as user, hiveloss as hive_loss"
              
    @query3 = @neo.execute_query(query_3)["data"]
    @query3_results = []
    
    for i in 0..@query3.length-1
      @query3_results.push(@query3[i].first["data"]) unless @query3_results.include?(@query3[i].first["data"])
    end
    
    puts @query3_results
  end
end

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
    
    products = params[:products].reject! { |c| c.empty? }
    months = params[:months].reject! { |c| c.empty? }

    products.map! { |element| (element.downcase == "checkmite+") ? "checkmite" : element }

    ############################
    ## THIS IS OUR MAIN QUERY ##
    ############################

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
    query_return = "RETURN COUNT(user) as num_users, SUM(hiveloss.value) as sum_loss"

    query = query_start + query_match + query_where + query_with_distinct + query_match2 + query_return
    
    puts query
    
    @loss = @neo.execute_query(query)["data"]
    
    @loss = JSON.parse(@loss.first.to_json)
    
    unless @loss[0] == 0 || @loss[1] == 0
      ratio = (@loss[1].to_f / @loss[0].to_f).to_f
      
      @ci_high = (ratio + (1.96 * (Math.sqrt(ratio) * (1.0 - ratio)) / @loss[0].to_f))
      @ci_low = (ratio - (1.96 * (Math.sqrt(ratio) * (1.0 - ratio)) / @loss[0].to_f))
      
      @confidence_interval = ((@ci_high - @ci_low) / 2.0).round(2)
      
      @results = true
    else
      @results = false
    end

    ####################################################
    ## THIS IS OUR QUERY MATCHING SELECTED PRODUCT(S) ##
    ####################################################
    
    query_start = "START "
    (0..products.length-1).each do |t|
      unless query_start.include?("#{products[t].downcase}=node:Products('name:#{products[t]}'), ")
        query_start += "#{products[t].downcase}=node:Products('name:#{products[t]}'), "
      end
    end
    query_start = query_start[0..-3]
    
    query_match = "MATCH "
    (0..products.length-1).each do |t|
      unless query_match.include?("(schedule) - [:APPLIED] -> (t) - [:PRODUCT_USED] -> (#{products[t].downcase}), ")
        query_match += "(schedule) - [:APPLIED] -> (t) - [:PRODUCT_USED] -> (#{products[t].downcase}), "
      end
    end
    query_match = query_match[0..-3]
    
    query_where = "WHERE (schedule.num_products = #{products.uniq.count}) "
    query_with_distinct = "WITH DISTINCT schedule "
    query_match2 = "MATCH (hiveloss) <- [:REPORTED] - (user) - [:USED] -> (schedule) "
    query_return = "RETURN COUNT(user) as num_users, SUM(hiveloss.value) as sum_loss"

    query = query_start + query_match + query_where + query_with_distinct + query_match2 + query_return
    
    puts ""
    puts ""
    puts ""
    puts ""
    puts query

    @products_only = @neo.execute_query(query)["data"].first


    unless @products_only[0] == 0 || @products_only[1] == 0
      ratio = (@products_only[1].to_f / @products_only[0].to_f).to_f * 0.01
      
      @po_ci_high = (ratio + (1.96 * (Math.sqrt(ratio) * (1.0 - ratio)) / @products_only[0].to_f)) * 100
      @po_ci_low = (ratio - (1.96 * (Math.sqrt(ratio) * (1.0 - ratio)) / @products_only[0].to_f)) * 100
      
      @po_confidence_interval = ((@po_ci_high - @po_ci_low) / 2.0).round(2)
      
      @po_results = true
    else
      @po_results = false
    end
    

    ##################################################
    ## THIS IS OUR QUERY MATCHING SELECTED MONTH(S) ##
    ##################################################

    query_start = "START "
    (0..months.length-1).each do |t|
      unless query_start.include?("#{months[t].downcase}=node:Months('name:#{months[t]}'), ")
        query_start += "#{months[t].downcase}=node:Months('name:#{months[t]}'), "
      end
    end
    query_start = query_start[0..-3]

    query_match = "MATCH "
    (0..months.length-1).each do |t|
      unless query_match.include?("(schedule) - [:APPLIED] -> (t#{t+1}) - [:DATE_APPLIED] -> (#{months[t].downcase}), ")
        query_match += "(schedule) - [:APPLIED] -> (t#{t+1}) - [:DATE_APPLIED] -> (#{months[t].downcase}), "
      end
    end
    query_match = query_match[0..-3]

    query_where = "WHERE (schedule.num_treatments = #{months.uniq.count}) "
    query_with_distinct = "WITH DISTINCT schedule "
    query_match2 = "MATCH (hiveloss) <- [:REPORTED] - (user) - [:USED] -> (schedule) "
    query_return = "RETURN COUNT(user) as num_users, SUM(hiveloss.value) as sum_loss"

    query = query_start + query_match + query_where + query_with_distinct + query_match2 + query_return
    
    puts ""
    puts ""
    puts ""
    puts ""
    puts query

    @months_only = @neo.execute_query(query)["data"].first
    
    unless @months_only[0] == 0 || @months_only[1] == 0
      ratio = (@months_only[1].to_f / @months_only[0].to_f).to_f * 0.01
      
      @mo_ci_high = (ratio + (1.96 * (Math.sqrt(ratio) * (1.0 - ratio)) / @months_only[0].to_f)) * 100
      @mo_ci_low = (ratio - (1.96 * (Math.sqrt(ratio) * (1.0 - ratio)) / @months_only[0].to_f)) * 100
      
      @mo_confidence_interval = ((@mo_ci_high - @mo_ci_low) / 2.0).round(2)
      
      @mo_results = true
    else
      @mo_results = false
    end
    
    respond_to do |format|
      format.html { render "results" }
#      format.js { render partial: "results"}
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

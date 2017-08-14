require 'mysql2'
require 'byebug'
mysql_errors = []
deleted_page_ids_with_urls = []
MYSQL_CLIENT = Mysql2::Client.new(host: "localhost", username: "root", password: "Vagrant123#",:database => "maropost_development", strict: false, reconnect: true)
SECURITY_TOKEN = '9edbc0b65186b1239cb25c0ad989711b0abf5521'
   account_ids = []
   result1 = MYSQL_CLIENT.query("Select id from accounts where active = true and enable_webtracking= true" )
   result1.each do |row|
     account_ids << row["id"]
   end
   account_ids.each do |account_id|
     website_ids = []
     result2 = MYSQL_CLIENT.query("Select id from webtracking.websites where account_id= #{account_id} and active = true")
     result2.each do |row|
       website_ids << row["id"]
     end
     website_ids.each do |website_id|
       all_urls = []
       result3 = MYSQL_CLIENT.query("Select url,hash_url from webtracking.pages#{account_id} where website_id = #{website_id}")
       result3.each do |row|
         all_urls << row
       end
       all_urls.each do |pair|
         response = Regexp.new('http(s)?://www.') =~ pair["url"]
         if response == 0
           puts "we have www in the URL"
           correct_url = pair["url"].gsub('www.','')
           parsed_url = URI.parse(correct_url)
           begin
             hash_url = Digest::SHA1.hexdigest("_#{SECURITY_TOKEN}_#{parsed_url.hostname}_ #{parsed_url.request_uri }_")
           rescue
             next
           end
           result4 = MYSQL_CLIENT.query("Select id from webtracking.pages#{account_id} where website_id=#{website_id} and hash_url='#{hash_url}'").first
           if result4 == nil
             puts "WEBTRACKING"
             # Web-tracking case:- no URL's without 'www' part
             begin
               MYSQL_CLIENT.query("Update webtracking.pages#{account_id} SET url= '#{correct_url}', hash_url= '#{hash_url}' where website_id= #{website_id} and hash_url= '#{pair["hash_url"]}'")
             rescue
               mysql_errors << ["Error in update Query"]
             end
           else
             puts "Recommendation"
             # Recommendation Case(574,396):- Duplicate URL's with & without 'www' part
             rpage_id = result4["id"]
             puts "Duplicate page is:- >>>>>#{rpage_id} "
             begin
               MYSQL_CLIENT.query("Delete from webtracking.pages#{account_id} where website_id= #{website_id} and id= #{rpage_id}")
               deleted_page_ids_with_urls << {rpage_id => pair["url"]}
             rescue
               mysql_errors << ["Error in Delete query"]
             end
             begin
               MYSQL_CLIENT.query("Update webtracking.pages#{account_id} SET url= '#{correct_url}', hash_url= '#{hash_url}' where website_id= #{website_id} and hash_url= '#{pair["hash_url"]}'")
             rescue
               mysql_errors << ["Error in update Query"]
             end
           end
         elsif response == nil
           puts "we don't have www part in the URL"
           next
         end
       end
     end
   end

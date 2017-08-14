require 'mysql2'
mysql_errors = []
deleted_page_ids_with_hash_urls = []
MYSQL_CLIENT = Mysql2::Client.new(host: "localhost", username: "root", password: "Vagrant123#",:database => "maropost_development", strict: false, reconnect: true)
SECURITY_TOKEN = '9edbc0b65186b1239cb25c0ad989711b0abf5521'
class DataUpdate

  def self.update_webtracking_data
    account_ids = []
    MYSQL_CLIENT.query("Select id from accounts where active = true and enable_webtracking= true" ).each do |row|
      account_ids << row["id"]
    end
    account_ids.each do |account_id|
      website_ids = []
      MYSQL_CLIENT.query("Select id from webtracking.websites where account_id= #{account_id} and active = true").each do |row|
        website_ids << row["id"]
      end
      website_ids.each do |website_id|
        all_urls = []
        MYSQL_CLIENT.query("Select id,url,hash_url from webtracking.pages#{account_id} where website_id = #{website_id}").each do |row|
          all_urls << row
        end
        puts ">>#{all_urls}"
        all_urls.each do |pair|
          response = Regexp.new('(http(s)?(://))?(www.)') =~ pair["url"]
          if response == 0
            puts "we have www in the URL"
            correct_url = pair["url"].gsub('www.','')
            parsed_url = URI.parse(correct_url)
            begin
              hash_url = Digest::SHA1.hexdigest("_#{SECURITY_TOKEN}_#{parsed_url.hostname}_ #{parsed_url.request_uri }_")
            rescue
              next
            end
            result1 = MYSQL_CLIENT.query("Select id from webtracking.pages#{account_id} where website_id=#{website_id} and hash_url='#{hash_url}'").first
            if result1 == nil
              puts "WEBTRACKING"
               # Web-tracking case:- no URL's without 'www' part
               begin
                 MYSQL_CLIENT.query("Update webtracking.pages#{account_id} SET url= '#{correct_url}', hash_url= '#{hash_url}' where website_id= #{website_id} and hash_url= '#{pair["hash_url"]}'")
               rescue
                 mysql_errors << ["Error in update Query of Pages"]
               end
            else
              puts "Recommendation"
               # Recommendation Case(574,396):- Duplicate URL's with & without 'www' part
              rpage_id = result1["id"]
              puts "Duplicate page is:- >>>>>#{rpage_id} "
               # Checking PageOpens before deletion.
               # this query of page_opens takes time.
              result2 = MYSQL_CLIENT.query("Select id from webtracking.page_opens#{account_id} where website_id=#{website_id} and page_id=#{rpage_id}").first
              if result2 == nil
                puts "We don't have any page_opens with page_id == #{rpage_id},which we are going to delete. "
              else
                begin
                  MYSQL_CLIENT.query("Update webtracking.page_opens#{account_id} SET page_id = #{pair["id"]} where website_id=#{website_id} and page_id=#{rpage_id}")
                rescue
                  mysql_errors << ["Error in update Query of PageOpens"]
                end
                 # this query of page_opens takes time.
                result3 = MYSQL_CLIENT.query("Select id from webtracking.page_opens#{account_id} where website_id=#{website_id} and parent_page_id=#{rpage_id}").first
                if result3 == nil
                  puts "We don't have any page_opens with parent_page_id == #{rpage_id},which we are going to delete."
                else
                  begin
                    MYSQL_CLIENT.query("Update webtracking.page_opens#{account_id} SET parent_page_id= #{pair["id"]} where website_id=#{website_id} and parent_page_id=#{rpage_id} ")
                  rescue
                    mysql_errors << ["Error in update Query of PageOpens"]
                  end
                end
              end
              begin
                MYSQL_CLIENT.query("Delete from webtracking.pages#{account_id} where website_id= #{website_id} and id= #{rpage_id}")
                deleted_page_ids_with_hash_urls << {rpage_id => hash_url}
              rescue
                mysql_errors << ["Error in Delete query of Pages"]
              end
              begin
                MYSQL_CLIENT.query("Update webtracking.pages#{account_id} SET url= '#{correct_url}', hash_url= '#{hash_url}' where website_id= #{website_id} and hash_url= '#{pair["hash_url"]}'")
              rescue
                mysql_errors << ["Error in update Query of Pages"]
              end
            end
          elsif response == nil
            puts "we don't have www part in the URL"
            next
          end
        end
      end
    end
  end
end

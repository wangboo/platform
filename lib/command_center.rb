#encoding: utf-8
require "active_record"
require "active_model"
require "mysql2"
#增强hash 和string
class Hash
  def to_query
    CGI::escape(each.inject(""){|sum,item|sum+="#{item[0]}=#{item[1]}&";sum}.match(/^(.*)\&$/)[1])
  end
end
class String
  def to_params
    CGI::unescape(self).split("&").inject({}){|hash,item|arr=item.split("=");hash[arr[0]]=arr[1];hash}
  end
end
# 通过用户名找人
def find_user_by_names
  UserInfo.where(nick_name: $conf["user"].split(',')).select("id")
end
# 通过条件查找
def find_user_by_condition
  regist_begin = ($conf["registBegin"] or 100.years.ago)
  regist_after = ($conf["registAfter"] or 1.years.since)
  level_smaller = ($conf["levelSmaller"] or 2000).to_i
  level_bigger = ($conf["levelBigger"] or 0).to_i
  sql = %Q{
    select i.id id from user_base b,user_info i where b.id=i.id and b.create_at between '#{regist_begin}' \
    and '#{regist_after}' and i.level between #{level_bigger} and #{level_smaller} 
  }
  # puts "sql = #{sql}"
  UserInfo.find_by_sql(sql)
end
def mail
  users = if $conf['user']
    find_user_by_names
  else
    find_user_by_condition
  end
  # puts $conf
  count = 0
  data = {
    sender_id: 0,
    sender_name: $conf['name'],
    type: 2,
    is_reward: $conf["type"] == 'reward' ? 1 : 0,
    reward: $conf['type'] == 'reward' ? $conf['reward'] : "",
    msg: $conf['message'],
    title: $conf['title'],
    is_maid: 0,
    is_request: 0
  }
  users.each do |info|
    data[:recver_id] = info.id
    SysMail.create(data);
    count += 1 
  end
  puts "一共发送了#{count}封邮件"
end

#清除所有用户数据
def clear_all_of_the_users
  %w{day_hero_exchange npc_arena_info sys_daylong sys_mail sys_market_price sys_req_times sys_version user_activity_reward user_arena_info user_auction user_barrier 
    user_base user_battle user_bloody_battle_day user_bloody_battle_five user_bloody_battle_totle user_chat user_day_reward user_decompose_hero user_draw_hero 
    user_duty_info user_equip user_exchange user_friends user_handbook user_hero user_info user_key user_maid user_maid_magic_tree user_market user_palace 
    user_practice_result user_props user_robber user_shop user_treasure user_update_attr_times}.each do |table_name|
    ActiveRecord::Base.connection.execute("delete from #{table_name}")
    ActiveRecord::Base.connection.execute("alter table #{table_name} AUTO_INCREMENT=1")
    puts "delete from #{table_name}"
  end
end

# puts ARGV
$conf = ARGV[0].to_params
$conf["mysql"] ||= "localhost"
# puts $conf
ActiveRecord::Base.pluralize_table_names = false
ActiveRecord::Base.inheritance_column = "spec_type"

class SysMail < ActiveRecord::Base;end
class UserBase < ActiveRecord::Base;end
class UserInfo < ActiveRecord::Base;end

ActiveRecord::Base.establish_connection({
  :adapter => "mysql2", 
  :host => $conf["mysql"], 
  :username => $conf["mysql_user"], 
  :password => $conf["mysql_pwd"],
  :database => $conf['mysql_db']
})

case $conf["cmd_name"]
when 'mail'
  mail
when 'clear_all_of_the_users'
  clear_all_of_the_users
end


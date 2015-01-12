file = '/home/chengdu/exports/account.base.csv'
dst_file = '/home/chengdu/exports/account.csv'
# file = '/Users/wangboo/Desktop/accounts.csv'
# dst_file = '/Users/wangboo/Desktop/accounts.csv.new'
%x(mongoexport -d platform -c accounts -o #{file} --csv -f aid,channel_id,channel_name,platform,vers,account_id,create_time,first_time,last_time,mac,ip,device,version)
dst = File.open(dst_file, 'w')
File.open(file).each_line do |l|
	dst.write l.gsub(/(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})Z/){$1+" "+$2 if $1 and $2}
end
dst.close
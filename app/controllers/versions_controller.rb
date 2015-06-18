# require_dependency Rails.root.join("lib", "properties.rb")

class VersionsController < ApplicationController
	# 删除其中一项
	def del_diff_item
		version = Version.find(params[:id])
		name = params[:name]
		puts "del name = #{name}"
		version.diff.reject!{|d|d['name'] == name}
		version.save
		render json: {r: true}
	end

	def show
			@platform = Platform.find params[:id]
			@versions = Version.where(platform_id: @platform.id).order("created_at desc")
	end

	def new
		@platform = Platform.find params[:id]
		@last_version = @platform.versions.last
		@new_version = Version.new
	end

	# 编辑一个version
	def edit
		@version = Version.find params[:id]
	end

	# 跟新一个version
	def update
		version = Version.find(params[:id])
		version.app_version = update_version_params
		diff = update_diff_params
		# 下载路径
		download_dir = JiyuProp.patch_download_path(version) << "assets/"
		puts "diff = #{diff}"
		diff.each_with_index do |d, index|
			old_d = version.diff[index]
			old_d['act'] = d[:act]
			if file = params["file_#{index}"]
				File.open("#{download_dir}#{d[:name]}", "wb") do |f|
					f.write file.tempfile.read
				end
				if file.tempfile.size == old_d['size']
					unless old_d == (the_md5 = md5 "#{download_dir}#{d[:name]}")
						old_d['code'] = md5 "#{download_dir}#{d[:name]}"
					end
				else
					old_d['size'] = file.tempfile.size
				end
			end
		end
		version.save
		redirect_to version_path(version.platform)
	end

	# 创建补丁
	def create
		platform = Platform.find(params[:platform_id])
		last_version = platform.versions.last
		# 创建version对象
		version = platform.versions.new create_version_params
		# 找到该平台的apk备份文件
		bak_file = JiyuProp.patch_bak_file version
		file = params[:version][:file]
		
		#存储apk文件
		File.open(bak_file, "wb") do |new_file|
			new_file.write file.read
		end
		file.close
		# 将apk解压到下载目录
		download_dir = JiyuProp.patch_download_path version
		Rails.logger.debug "unzip -o #{bak_file} -d #{download_dir}"
		%x/unzip -o #{bak_file} -d #{download_dir}/

		# 如果还没有创建第一版
		return redirect_to version_path(platform) unless last_version
		# 和上一版做比较
		last_dir = JiyuProp.patch_download_path last_version
		@diff = []
		# 差异比较
		compare_apk download_dir, last_dir
		# 合并上版本差异
		diff_merge version, last_version
		# 赋值
		version.diff = @diff		
		version.save!
		# 生成flist文件
		VersionsController.save_flist version
		redirect_to version_path(platform)
	end

	# 将本次diff 与 last_diff合并
	def diff_merge version, last_version
		return if last_version == nil or last_version.diff.empty?
		path = JiyuProp.patch_download_path version
		last_version.diff.reduce @diff do |arr, item|
			if not arr.any?{|hash|hash["name"] == item["name"]} and File.exist? "#{path}assets/#{item['name']}"
				# 文件还存在
				arr << item
			else
				puts "file #{path}assets/#{item['name']} not exist!!"
			end
			arr
		end
	end

	# 差异文件展示
	def diff
		@version = Version.find params[:id]
		@platform = @version.platform
		# Rails.logger.debug @version.diff
	end

	# 差异文件flist
	def flist
		version = Version.find(params[:id])
		platform = version.platform
		@flist = 'local list = {ver="'
		@flist << "#{version.app_version}"
		@flist << '",baseURL="'
		@flist << "#{platform.download_url}download/#{platform.mask}/#{version.version}/assets/"
		@flist << '",stage={'
		version.diff.each do |item|
			VersionsController.to_flist_style(@flist, item)
		end
		@flist << "},remove={}} return list"		
	end

	private
	def create_version_params
		params.require("version").permit(:version, :desc, :app_version)
	end
	# 更新版本参数
	def update_version_params
		params.require(:version).require(:app_version)
	end
	# 更新差异参数
	def update_diff_params
		params.require(:diff)
	end
  # 项目比较
	def compare_apk new_dir, old_dir
		Rails.logger.debug "new #{new_dir}assets/res, old #{old_dir}assets/res"
		compare_path "#{new_dir}assets/res", "#{old_dir}assets/res", "res/"
	end

	# 目录比较
	def compare_path new_dir, old_dir, prefix
		new_dirs = Dir.entries(new_dir).select{|name|filename_filter name}
		old_dirs = Dir.entries(old_dir).select{|name|filename_filter name}
		# 多的
		more = new_dirs - old_dirs
		puts "more list #{more}"
		more.each do |name|
			new_filepath = "#{new_dir}/#{name}"
			if Dir.exist? new_filepath
				# 是目录
				add_diff_dir new_filepath, "#{prefix}#{name}/"
			else
				# 是文件
				add_diff "name" => "#{prefix}#{name}", "size" => File.size(new_filepath), "act" => load?(name)
			end
		end

		# 相同的元素
		same = new_dirs & old_dirs
		same.each do |name|
			new_filepath = "#{new_dir}/#{name}"
			if Dir.exist? new_filepath
				# 是目录
				compare_path new_filepath, "#{old_dir}/#{name}/", "#{prefix}#{name}/"
			else
				# 是文件
				test_diff new_filepath, "#{old_dir}/#{name}", prefix, name
			end
		end
		# 已删除的 TODO
	end

	# 将path下的所有合法文件加入diff中
	def add_diff_dir path, prefix
		Dir.entries(path).select{|name|filename_filter name}.each do |name|
			filepath = "#{path}/#{name}"
			if Dir.exist? filepath
				# 如果是目录，那么遍历
				Rails.logger.debug "add_diff_dir #{prefix}#{name}/"
				add_diff_dir filepath, "#{prefix}#{name}/"
			else
				# 如果是文件，那么加入差异文件中
				add_diff "name" => "#{prefix}#{name}", "size" => File.size(filepath), "act" => load?(name)
			end
		end
	end

	def filename_filter name
		name != '.' and name !='..' and name != '.DS_Store'
	end

	# 增加差异文件
	def test_diff new_filepath, old_filepath, prefix, name
		# 优先比较文件长度，如果长度不一样那么记录差异文件
		new_size = File.size(new_filepath)
		old_size = File.size(old_filepath)
		if new_size == old_size
			new_md5 = normal_md5 new_filepath
			old_md5 = normal_md5 old_filepath
			if new_md5 != old_md5
				app_md5 = md5 new_filepath
				add_diff "name" => "#{prefix}#{name}", "code" => app_md5, "size" => new_size, "act" => load?(name)
			else
				# puts "same! #{new_filepath}"
			end
		else
				add_diff "name" => "#{prefix}#{name}", "size" => new_size, "act" => load?(name)
		end
	end

	# 是否act为load
	def load? name
		name == 'game.zip' ? "load" : nil
	end
	# 后台md5算法
	def normal_md5 filepath
		Digest::MD5.hexdigest(File.open(filepath).read)
	end
	# 前台md5算法
	def md5 filepath
		Digest::MD5.hexdigest(
			File.open(filepath, 'r').each_byte.inject("") do|sum, b|
				str = b.to_s(16)
				str.upcase!
				if str.size == 1
					sum << "0#{str}"
				else
					sum << str
				end
			end
		)
	end

	def add_diff item
		@diff << item
	end

	# 生成并保存flist文件
	def self.save_flist version
		version = Version.new unless version
		platform = version.platform
		flist = 'local list = {ver="'
		flist << "#{version.app_version}"
		flist << '",baseURL="'
		flist << "#{platform.download_url}download/#{platform.mask}/#{version.version}/assets/"
		flist << '",stage={'
		version.diff.each do |item|
			to_flist_style(flist, item)
		end
		flist << "},remove={}} return list"
		AppController.flist_cache[platform.mask] = flist
	end

	# 将每一样的差异item转换为前台需要的格式
	def self.to_flist_style flist, item
		# Rails.logger.debug "item=#{item}"
		flist << '{name="'
		flist << item["name"].strip
		flist << '",'
		if item.include? "code" and not item['code'].strip.empty?
			flist << 'code="'
			flist << item["code"].strip
			flist << '",'
		end
		flist << "size=#{item["size"]},"
		if item["act"]  and not item['act'].strip.empty?
			flist << 'act="'
			flist << item["act"].strip
			flist << '"'
		else
			flist << "act=null"
		end
		flist << "},"
	end

end

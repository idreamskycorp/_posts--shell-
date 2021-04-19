
class BlogCreateManager
    attr_accessor :fileName, :createDate, :title, :tag, :fullFileName
    def input_file_name
        puts "输入文件名"
        @fileName = gets
        if @fileName.gsub(/\s+/,"").empty?
            puts "输入不合法"
            input_file_name
        else
            @fileName = @fileName.gsub(/\s+/,"")
        end
    end

    def input_create_date
        puts %q{
            1.使用当前时间创建
            2.手动输入创建
            3.随机创建时间
        }
        option = gets
        case option.to_i
        when 1
            @createDate = Time.new.strftime("%Y-%m-%d")
        when 2
            puts "输入创建时间"
            timeStr = gets
            if timeStr.gsub(/\s+/,"").empty?
                puts "输入不合法"
                input_create_date
            elsif timeStr =~ /\d{4}-\d{2}-\d{2}/
                @createDate = timeStr.gsub(/\s+/,"")
            else
                puts "输入不合法"
                input_create_date
            end
        when 3
            year = rand(2015..2021)
            month = rand(1..12)
            day = rand(1..28)
            date = Time.new(year, month, day)
            puts date.to_s
            if date > Time.now
                @createDate = Time.now.strftime("%Y-%m-%d")
            else
                @createDate = date.strftime("%Y-%m-%d")
            end
        else
            puts "没有查到你要输入的序列号"
            input_create_date
        end
    end

    def input_title
        puts "输入文章标题"
        @title = gets
        if @title.gsub(/\s+/,"").empty?
            puts "输入标题不合法"
            input_title
        else
            @title = @title.gsub(/\s+/,"")
        end
    end

    def input_tag
        puts "输入tag"
        @tag = gets
        if @tag.gsub(/\s+/,"").empty?
            puts "输入标题不合法"
            input_tag
        else
            @tag = @tag.chomp
        end
    end

    def start_input
        input_file_name
        sleep 0.3
        input_create_date
        sleep 0.3
        input_title
        sleep 0.3
        input_tag
        sleep 0.3
    end

    def create_blog_file
        Dir.chdir("_posts") do
            puts Dir.pwd
            @fullFileName = @createDate + '-' + @fileName + ".md"
            File.open(@fullFileName,"w+") do |f|
                content = %Q{---
layout: post
title: #{@title}
date: #{createDate}
tags: #{tag}
---}
                f.puts content
            end
          end
    end

end

manager = BlogCreateManager.new
manager.start_input
puts '-----------'
puts "你输入的文件名为"
puts manager.fileName
puts "你输入的标题为"
puts manager.title
puts "你输入的创建时间为"
puts manager.createDate
puts "你输入的tag为"
puts manager.tag
manager.create_blog_file
sleep 0.5
puts "---------创建完毕------------"
system("open ./_posts/#{manager.fullFileName} -a XCode")
#"2014-04-01" =~ /\d{4}-\d{2}-\d{2}/
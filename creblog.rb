
# puts "输入文件名"
# filename = gets
# puts "你输入的文件名为#{filename}"

# $fileName = "xxxx"
# def input_file_name
#     # puts "输入文件名"
#     puts $fileName
# end

# input_file_name

class BlogCreateManager
    attr_accessor :fileName, :createDate, :title, :tag
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
            @tag = @tag.gsub(/\s+/,"")
        end
    end

    def start_input
        input_file_name
        input_create_date
        input_title
        input_tag
    end

    def create_blog_file
        Dir.chdir("_posts") do
            puts Dir.pwd
            blog_file_name = @createDate + '-' + @fileName + ".md"
            File.open(blog_file_name,"w+") do |f|
                content = %Q{
---
layout: post
title: #{@title}
date: #{createDate}
tags: #{tag}   
---
                }
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

manager.create_blog_file
#"2014-04-01" =~ /\d{4}-\d{2}-\d{2}/
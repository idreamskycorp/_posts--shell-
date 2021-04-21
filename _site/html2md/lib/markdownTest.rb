
require './html2md'
require 'open-uri'

html2md = Html2Md.new(open("https://www.jianshu.com/p/2d57c72016c6").read)
puts html2md.parse
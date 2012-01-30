# -*- encoding: utf-8 -*-
require 'cora'
require 'siri_objects'
require 'eat'
require 'nokogiri'
require 'timeout'


#######
#
# This is simple plugin which shows the open Heurigen-restaurants in Perchtoldsdorf/Austria
#
#       Remember to put this plugins into the "./siriproxy/config.yml" file 
#######
#
# Diese plugin. zeigt welche Heurigen in Perchtoldsdorf/Österreich ausgesteckt haben.
# 
#      ladet das Plugin in der "./siriproxy/config.yml" datei !
#
#######
## ##  WIE ES FUNKTIONIERT 
#
# sagt "ausgesteckt" + "heute" oder "morgen" 
#
# bei Fragen Twitter: @muhkuh0815
# oder github.com/muhkuh0815/siriproxy-pdorf
# Video ---
#
#
#### ToDo
#
#  maybe add Viennese Heurigen, if i find a good site to parse
#
#######


class SiriProxy::Plugin::Pdorf < SiriProxy::Plugin
    
    def initialize(config)
        #if you have custom configuration options, process them here!
    end
    def doc
    end
    def docs
    end
    def datum(plu)
    time = Date.today
    ttime = time + plu
    time1 = ttime.month.to_s + "/" + ttime.day.to_s + "/" + ttime.year.to_s
    return time1
    end
    def datun(plu)
    time = Date.today
    ttime = time + plu
    time1 = ttime.day.to_s + "." + ttime.month.to_s + "." + ttime.year.to_s
    return time1
    end
    def read(ta)
      @shaf = ""
      begin
	doc = Nokogiri::HTML(eat("http://www.pdorf.at/Nuke5/modules.php?op=modload&name=Calendar&file=index&Date=" + ta.to_s + "&type=day"))
	doc.encoding = 'utf-8'
      rescue Timeout::Error
	print "Timeout-Error beim Lesen der Seite"
	@shaf ="timeout"
      rescue
	print "Lesefehler !"
	@shaf ="timeout"
      end
      if @shaf =="timeout" 
      say "Es gab ein Problem beim Einlesen der der Daten!"
      else
      doc = doc.to_s
      dat = doc.match(/(bally.gif)/)
      dat2 = dat.post_match
      dat = dat2.match(/(d3e5b3)/)
      data = dat.pre_match
      data = data.insert(0, "<")
      data = data.insert(-1, ">")
      data = data.gsub(/\/php\//, ">,newline,<")
      data = data.gsub(/<\/?[^>]*>/, "")
      data = data.strip
      dat = data.split(',')
      datle = dat.length
      dataa = Array.new
      data = ""
      y = 0
      dat.each do |name|
	if name == "newline"
	  data = data.chop.chop
	  data = data.strip
	  dataa[y] = data
	  data = ""
	  y += 1
	elsif name.strip == ""
	else
	  data << name.strip + ", "
	end
      end
      @y= y - 1
      data = ""
      dataa.each do |line|
	data << line + " \n\n"
      end
      end
      return data
    end
    
    
listen_for /(ausgesteckt|ausgestreckt).*(heute)/i do
    datu = datum(0)
    datunorm = datun(0)
    shaf = ""
    doc = read(datu)
    if @shaf =="timeout" 
      say "Es gab ein Problem beim Einlesen der der Daten!"
    else
	y = @y
	@y = ""
 	if y == 1
	  say "", spoken: "heute hat #{y} Häuriger ausgsteckt"
        else
	  say "", spoken: "heute haben #{y} Häurige ausgsteckt"
        end    
	object = SiriAddViews.new
    		object.make_root(last_ref_id)
    		answer = SiriAnswer.new("heute: " + datunorm.to_s, [
    	  		SiriAnswerLine.new(doc)
		        ])
    		object.views << SiriAnswerSnippet.new([answer])
    		send_object object
    end    
request_completed
end

listen_for /(heute).*(ausgesteckt|ausgestreckt)/i do
    datu = datum(0)
    datunorm = datun(0)
    shaf = ""
    doc = read(datu)
    if @shaf =="timeout" 
      say "Es gab ein Problem beim Einlesen der der Daten!"
    else
	y = @y
	@y = ""
 	if y == 1
	  say "", spoken: "heute hat #{y} Häuriger ausgsteckt"
        else
	  say "", spoken: "heute haben #{y} Häurige ausgsteckt"
        end    
	object = SiriAddViews.new
    		object.make_root(last_ref_id)
    		answer = SiriAnswer.new("heute: " + datunorm.to_s, [
    	  		SiriAnswerLine.new(doc)
		        ])
    		object.views << SiriAnswerSnippet.new([answer])
    		send_object object
    end    
request_completed
end

listen_for /(ausgesteckt|ausgestreckt).*(morgen)/i do
    datu = datum(1)
    datunorm = datun(1)
    shaf = ""
    doc = read(datu)
    if @shaf =="timeout" 
      say "Es gab ein Problem beim Einlesen der der Daten!"
    else
	y = @y
	@y = ""
 	if y == 1
	  say "", spoken: "morgen hat #{y} Häuriger ausgsteckt"
        else
	  say "", spoken: "morgen haben #{y} Häurige ausgsteckt"
        end    
	object = SiriAddViews.new
    		object.make_root(last_ref_id)
    		answer = SiriAnswer.new("morgen: " + datunorm.to_s, [
    	  		SiriAnswerLine.new(doc)
		        ])
    		object.views << SiriAnswerSnippet.new([answer])
    		send_object object
    end    
request_completed
end

listen_for /(morgen).*(ausgesteckt|ausgestreckt)/i do
    datu = datum(1)
    datunorm = datun(1)
    shaf = ""
    doc = read(datu)
    if @shaf =="timeout" 
      say "Es gab ein Problem beim Einlesen der der Daten!"
    else
	y = @y
	@y = ""
 	if y == 1
	  say "", spoken: "morgen hat #{y} Häuriger ausgsteckt"
        else
	  say "", spoken: "morgen haben #{y} Häurige ausgsteckt"
        end    
	object = SiriAddViews.new
    		object.make_root(last_ref_id)
    		answer = SiriAnswer.new("morgen: " + datunorm.to_s, [
    	  		SiriAnswerLine.new(doc)
		        ])
    		object.views << SiriAnswerSnippet.new([answer])
    		send_object object
    end    
request_completed
end

end

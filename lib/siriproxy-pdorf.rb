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
    def getloc(na)
      na = na.gsub(" ","+")
		dos = "http://maps.google.com/maps/api/geocode/xml?address=" + na.to_s + ",+Perchtoldsdorf&sensor=false"
		begin
			dos = URI.parse(URI.encode(dos)) # allows Unicharacters in the search URL
			doc = Nokogiri::XML(open(dos))
			doc.encoding = 'utf-8'
# 			doc = doc.text
		rescue Timeout::Error
    	 	doc = ""
		end
		if doc == NIL
		  say "Fehler beim Suchen - no data", spoken: "Fehler beim Suchen" 
		  request_completed
		elsif
		  empl = doc.to_s
		  la = empl.match(/(lat)/)
		  lo = la.post_match
		  li = lo.match(/(\/lng)/)
		  lu = li.pre_match
 		  lu = lu.gsub("<lng>",",")
		  lu = lu.gsub(/<\/?[^>]*>/, "")
		  lu = lu.gsub(/\n/, "")
		  lu = lu.gsub("  ", "")
		  lu.chop!
		  lu.reverse!
		  lu.chop!
		  lu.reverse!
		  lu.strip!
# 		  print lu
		end
	return lu	
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
      dat = data.match(/(,newline,)/)
      data = dat.post_match
      dat = data.split(',')
      datle = dat.length
      @dataa = Array.new
      @datab = Array.new
      data = ""
      y = 0
      z = 0
      dat.each do |name|
	if name == "newline"
	  z = 0
	  data = data.chop.chop
	  data = data.strip
	  @dataa[y] = data
	  data = ""
	  y += 1
	elsif z == 2
	  al = getloc(name)
	  @datab[y] = al.strip
	  data << name.strip + ", "
	elsif name.strip == ""
	else
 	  if name[0,5] == " Stüb"
	  else
	  data << name.strip + ", "
	  end
	 end
	z += 1
      end
      @y= y - 1
      end
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
	dataa = @dataa
	datab = @datab
	@dataa = ""
	@datab = ""
 	add_views = SiriAddViews.new
	add_views.make_root(last_ref_id)
    		map_snippet = SiriMapItemSnippet.new(true)
			z = 0
			while z < y do
			la = dataa[z].split(",")
			sname = la[0].strip
			li = datab[z]
			lo = li.match(/,/)
			lat = lo.pre_match
			lon = lo.post_match
    			siri_location = SiriLocation.new(sname, la[1].strip, la[2].strip,"9", "AT", "Perchtoldsdorf" , lat.to_s , lon.to_s)
    			map_snippet.items << SiriMapItem.new(label=sname , location=siri_location, detailType="BUSINESS_ITEM")
    			z += 1
 			end
			if y.to_s == 1	
				say "", spoken: "heute hat #{y} Häuriger ausgsteckt"
			else	
				say "", spoken: "heute haben #{y} Häurige ausgsteckt"
			end	
			utterance = SiriAssistantUtteranceView.new("")
    		add_views.views << utterance
    		add_views.views << map_snippet
    		send_object add_views 
    end  
    @dataa = ""
    @datab = ""
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
	dataa = @dataa
	datab = @datab
	@dataa = ""
	@datab = ""
 	add_views = SiriAddViews.new
	add_views.make_root(last_ref_id)
    		map_snippet = SiriMapItemSnippet.new(true)
			z = 0
			while z < y do
			la = dataa[z].split(",")
			sname = la[0].strip
			li = datab[z]
			lo = li.match(/,/)
			lat = lo.pre_match
			lon = lo.post_match
    			siri_location = SiriLocation.new(sname, la[1].strip, la[2].strip,"9", "AT", "Perchtoldsdorf" , lat.to_s , lon.to_s)
    			map_snippet.items << SiriMapItem.new(label=sname , location=siri_location, detailType="BUSINESS_ITEM")
    			z += 1
 			end
			if y.to_s == 1	
				say "", spoken: "heute hat #{y} Häuriger ausgsteckt"
			else	
				say "", spoken: "heute haben #{y} Häurige ausgsteckt"
			end	
			utterance = SiriAssistantUtteranceView.new("")
    		add_views.views << utterance
    		add_views.views << map_snippet
    		send_object add_views 
    end  
    @dataa = ""
    @datab = ""
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
	dataa = @dataa
	datab = @datab
	@dataa = ""
	@datab = ""
 	add_views = SiriAddViews.new
	add_views.make_root(last_ref_id)
    		map_snippet = SiriMapItemSnippet.new(true)
			z = 0
			while z < y do
			la = dataa[z].split(",")
			sname = la[0].strip
			li = datab[z]
			lo = li.match(/,/)
			lat = lo.pre_match
			lon = lo.post_match
    			siri_location = SiriLocation.new(sname, la[1].strip, la[2].strip,"9", "AT", "Perchtoldsdorf" , lat.to_s , lon.to_s)
    			map_snippet.items << SiriMapItem.new(label=sname , location=siri_location, detailType="BUSINESS_ITEM")
    			z += 1
 			end
			if y.to_s == 1	
				say "", spoken: "morgen hat #{y} Häuriger ausgsteckt"
			else	
				say "", spoken: "morgen haben #{y} Häurige ausgsteckt"
			end	
			utterance = SiriAssistantUtteranceView.new("")
    		add_views.views << utterance
    		add_views.views << map_snippet
    		send_object add_views 
    end  
    @dataa = ""
    @datab = ""
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
	dataa = @dataa
	datab = @datab
	@dataa = ""
	@datab = ""
 	add_views = SiriAddViews.new
	add_views.make_root(last_ref_id)
    		map_snippet = SiriMapItemSnippet.new(true)
			z = 0
			while z < y do
			la = dataa[z].split(",")
			sname = la[0].strip
			li = datab[z]
			lo = li.match(/,/)
			lat = lo.pre_match
			lon = lo.post_match
    			siri_location = SiriLocation.new(sname, la[1].strip, la[2].strip,"9", "AT", "Perchtoldsdorf" , lat.to_s , lon.to_s)
    			map_snippet.items << SiriMapItem.new(label=sname , location=siri_location, detailType="BUSINESS_ITEM")
    			z += 1
 			end
			if y.to_s == 1	
				say "", spoken: "morgen hat #{y} Häuriger ausgsteckt"
			else	
				say "", spoken: "morgen haben #{y} Häurige ausgsteckt"
			end	
			utterance = SiriAssistantUtteranceView.new("")
    		add_views.views << utterance
    		add_views.views << map_snippet
    		send_object add_views 
    end  
    @dataa = ""
    @datab = ""
request_completed
end

end

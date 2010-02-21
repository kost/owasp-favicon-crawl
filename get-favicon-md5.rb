#!/usr/bin/env ruby
require 'net/http'
require 'digest/md5'
require 'uri'

threads = []
t=0;
maxthreads=512;
progress=512
totalurls = 0;
totalfavicons = 0;

def get_favicon (myPage, limit = 5) 
	rval = Array.new(0);
	getreq = myPage+"/favicon.ico"
	# $stderr.print "Fetching: #{getreq}\n"
	return rval if limit == 0

	begin
	url = URI.parse(getreq)
	req = Net::HTTP::Get.new(url.path)
	resp = Net::HTTP.start(url.host, url.port) {|http|
		http.read_timeout = 60
		http.request(req)
	}
	# $stderr.print "Got #{myPage}:  #{resp.message}\n"

	case resp
		when Net::HTTPSuccess then
			digest = Digest::MD5.hexdigest(resp.body)
			# $stderr.print "MD5 #{myPage}: #{resp.message} (#{digest})\n"
			rval[0]=1
			rval[1]=myPage
			rval[2]=digest
		when Net::HTTPRedirection then 
			getreq=resp['location']
			getreq=myPage+getreq if (not getreq.match('^http'))
			rval=get_favicon(getreq, limit - 1)
	end
	rescue Timeout::Error
		$stderr.print "TError: "+myPage+"\n"
	rescue 
		$stderr.print "Error: "+myPage+"\n"
	end		
	return rval
end

while (str=gets) 
	str=str.chomp
	# $stderr.print "Line: "+str+";\n"
	totalurls+=1
	$stderr.print "#{totalurls}\n" if (totalurls % progress == 0) 
	if (not str.match('^http')) then next; end
	if (t<maxthreads) then
		threads << Thread.new(str) { |url|
			out=get_favicon(url);
			if (out[0]==1) then puts out[2]+","+out[1]; totalfavicons+=1; end
		}
		t+=1
	else
		toexit=0
		while (1)
		for i in 1..t-1 
			if (threads[i].join(0)) then
				threads[i].join
				threads[i]=Thread.new(str) { |url|
					out=get_favicon(url);
					if (out[0]==1) then puts out[2]+","+out[1]; totalfavicons+=1; end
				}
				toexit=1
				break	
			end
		end
		if (toexit==1) then break; end
		end
	end
end

threads.each { |cThread|  
	cThread.join 
}

$stderr.print "Found #{totalfavicons} of total URLs: #{totalurls}\n"


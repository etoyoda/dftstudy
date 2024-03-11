#!/usr/bin/ruby

of=ofp=nil
ofs=[]

for line in ARGF
  case line
  when /^```c:(.*\.c)\s*/ then
    of = $1
    ofp = File.open(of, "wt")
    ofs.push of
  when /^```\s*$/ then
    raise "closing un-opened file" if of.nil?
    ofp.close
    of = ofp = nil
  else
    ofp.puts line if of
  end
end

def run cmd
  STDERR.puts "$ #{cmd}"
  rc = system(cmd)
  unless rc
    STDERR.puts "rc=#{rc}"
    exit 1
  end
end

run "gcc -oa.out #{ofs.join(' ')} -lm"
run "./a.out"

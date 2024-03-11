#!/usr/bin/ruby

of=ofp=src=log=nil

for line in ARGF
  case line
  when /^```c:(\S+\.c)\s*/ then
    src = of = $1
    ofp = File.open(of, "wt")
  when /^```text:(\S+)\s*$/ then
    log = of = $1
    ofp = File.open(of, "wt")
  when /^```\s*$/ then
    if of then
      ofp.close
      of = ofp = nil
    end
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

raise "no source" if src.nil?
run "gcc -oa.out #{src} -lm"
run "./a.out > z-log.txt"
run "diff -u #{log} - < z-log.txt" if log
run "rm -f z-log.txt #{src} #{log}"

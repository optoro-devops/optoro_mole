#!/usr/bin/env ruby
require 'pp'

# get all running sshd connections that are currently established
processes = `sudo netstat -tnpa | grep ESTABLISHED.*sshd | grep -v 6379`.split("\n")

# get only foreign ip and PID
sshds_map = processes.map do |r|
  cells = r.split
  [cells[4].split(':')[0], cells[6].split('/')[0]]
end

# sshd connections with pids, ips and elapsed time
sshds_map_with_times = {}

# parsed output of ps command
ps_output = {}
pids_with_commands = {}

# get everything from ps
times_formatted = `ps -eo pid,etime --no-headers`.split("\n")

# populate ps_output with {pid => elapsed_time in seconds}
times_formatted.each do |line|
  s = line.strip.split(/\s+/)
  time_formatted = s[1].split(/-|:/).reverse
  time_seconds = time_formatted[0].to_i + (time_formatted[1].to_i * 60) + (time_formatted[1].to_i * 60 * 60) + (time_formatted[1].to_i * 60 * 60 * 24)
  ps_output[s[0]] = time_seconds
end

# get bash PIDs with their commands
processes_hierarchy = `ps -efH | grep -A2 "sshd: printer \\[priv\\]" | grep -v "\\-\\-"`.split("\n")

processes_hierarchy.each_with_index do |line, i|
  if line =~ /bash/
    command = line.match(/bash.+$/)[0]
    i.downto(0) do |j|
      if processes_hierarchy[j].split(' ')[0] == 'root'
        pids_with_commands[processes_hierarchy[j].split(' ')[1]] = command
        break
      else
        next
      end
    end
  end
end

# match up times and pids to ipadresses like so { ip => { command => [[elapsed_time_seconds,pid]]} }
sshds_map.each do |proc|
  next if ps_output[proc[1]].nil? || pids_with_commands[proc[1]].nil?
  ip = proc[0]
  command = pids_with_commands[proc[1]]

  if sshds_map_with_times[ip]
    if sshds_map_with_times[ip][command]
      sshds_map_with_times[ip][command] << [ps_output[proc[1]], proc[1]]
    else
      sshds_map_with_times[ip][command] = [[ps_output[proc[1]], proc[1]]]
    end
  else
    sshds_map_with_times[ip] = { command => [[ps_output[proc[1]], proc[1]]] }
  end
end

# sort every entry in sshds_map_with_times by time elapsed and then kill all the processes(which will kill all of the children)
# except for the one that has been running the least amount of time
sshds_map_with_times.keys.each do |ip|
  sshds_map_with_times[ip].keys.each do |command|
    if command =~ /echo\s(\d+)\s>/
      parent_pid = nil
      begin
        port = command.match(/echo\s(\d+)\s>/)[1]
        pid_keeping_connection_open = `sudo netstat -tnpa | grep #{port}`.match(/\s(\d+)\/sshd:/)[1]
        parent_pid = `sudo ps --pid #{pid_keeping_connection_open} -o ppid --no-headers`.strip
      rescue # rubocop:disable HandleExceptions
      end
      sshds_map_with_times[ip][command].each do |process|
        `kill #{process[1]}` unless process[1] == parent_pid
      end
    else
      sshds_map_with_times[ip][command].sort { |a, b| a[0] <=> b[0] }.each_with_index do |process, i|
        if i == 0
          next
        else
          `kill #{process[1]}`
        end
      end
    end
  end
end

# https://stuff-things.net/2017/03/22/capistrano-ssh/
desc 'SSH to first app (db) instance'
task :ssh do
  on roles(:db) do |host|
    command = "cd #{fetch(:deploy_to)}/current && exec $SHELL -l"
    puts command if fetch(:log_level) == :debug
    exec "ssh -i #{host.ssh_options[:keys]} -l #{host.user} #{host.hostname} -p #{host.port || 22} -t '#{command}'"
  end
end

desc 'SSH to app instance'
task 'ssh-second' do
  on roles(:app) do |host|
    command = "cd #{fetch(:deploy_to)}/current && exec $SHELL -l"
    puts command if fetch(:log_level) == :debug
    exec "ssh -i #{host.ssh_options[:keys]} -l #{host.user} #{host.hostname} -p #{host.port || 22} -t '#{command}'"
  end
end

desc 'SSH to worker instance'
task 'ssh-worker' do
  on roles(:worker) do |host|
    command = "cd #{fetch(:deploy_to)}/current && exec $SHELL -l"
    puts command if fetch(:log_level) == :debug
    exec "ssh -i #{host.ssh_options[:keys]} -l #{host.user} #{host.hostname} -p #{host.port || 22} -t '#{command}'"
  end
end

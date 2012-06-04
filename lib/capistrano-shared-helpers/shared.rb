unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano-checks requires Capistrano 2"
end

require 'capistrano-shared-helpers/ext/remote_dependency'

Capistrano::Configuration.instance.load do
  namespace :deploy do
    namespace :shared do

      desc <<-DESC
      Add checks to ensure paths in :shared exist on remote server.
      DESC
      task :check, :except => { :no_release => true } do
        fetch(:shared, []).each do |path|
          depend :remote, :path, File.join(shared_path, path)
        end
      end

      desc <<-DESC
      Create parent dirs for paths in :shared on remote server.

      This task is run after deploy:setup.
      DESC
      task :setup, :except => { :no_release => true } do
        if exists?(:shared)
          dirs = shared.map {|path| File.join(shared_path, File.dirname(path)) }
          unless dirs.empty?
            run "#{try_sudo} mkdir -p #{dirs.join(' ')}"
            run "#{try_sudo} chmod g+w #{dirs.join(' ')}" if fetch(:group_writable, true)
          end
        end
      end

      desc <<-DESC
      Upload files/dirs in :shared from local to remote shared path.
      DESC
      task :upload, :except => { :no_release => true } do
        if exists?(:shared)
          shared.each do |path|
            top.upload(path, File.join(shared_path, path),
                       :via => :scp, :recursive => true)
          end
        end
      end

    end # namespace :shared
  end # namespace :deploy

  before 'deploy:check', 'deploy:shared:check'
  after 'deploy:setup', 'deploy:shared:setup'
  before 'deploy:shared:upload', 'deploy:shared:setup'

end


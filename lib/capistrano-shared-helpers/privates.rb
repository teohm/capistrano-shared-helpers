unless Capistrano::Configuration.respond_to?(:instance)
  abort "capistrano-checks requires Capistrano 2"
end

require 'capistrano-shared-helpers/ext/remote_dependency'

Capistrano::Configuration.instance.load do
  namespace :deploy do
    namespace :privates do

    desc <<-DESC
      Add checks to ensure paths in :privates exist on remote server.
    DESC
    task :check, :except => { :no_release => true } do
      fetch(:privates, []).each do |path|
        depend :remote, :path, File.join(shared_path, 'private', path)
      end
    end

    desc <<-DESC
      Create parent dirs for paths in :shared on remote server.

      This task is run after deploy:setup.
    DESC
    task :setup, :except => { :no_release => true } do
      dirs = fetch(:privates, []).map {|path| File.join(shared_path, 'private', File.dirname(path)) }
      unless dirs.empty?
        run "#{try_sudo} mkdir -p #{dirs.join(' ')}"
      end
    end

    desc <<-DESC
      Upload files/dirs in :shared from local to remote shared private path.
    DESC
    task :upload, :except => { :no_release => true } do
      fetch(:privates, []).each do |path|
        top.upload(path, File.join(shared_path, 'private', path), 
                   :via => :scp, :recursive => true)
      end
    end

    end # namespace :privates
  end # namespace :deploy

  before 'deploy:check', 'deploy:privates:check'
  after 'deploy:setup', 'deploy:privates:setup'
  before 'deploy:privates:upload', 'deploy:privates:setup'

end


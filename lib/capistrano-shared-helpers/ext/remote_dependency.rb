require 'capistrano/recipes/deploy/remote_dependency'

Capistrano::Deploy::RemoteDependency.class_eval do

  # Test if the path exists on remote server.
  def path(path, options={})
    @message ||= "`#{path}' directory or file is missing"
    try("test -e #{path}", options)
    self
  end
end


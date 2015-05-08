# Place this script inside the repository you want to backup to.
# Make sure you have ssh-keys working for git.

require 'octokit'

# Your Github credentials go here.
gh_user = ""
gh_pass = ""

puts "\n\n---Backing up all your Github repositories to this one----"
puts "---Using User:#{gh_user}----"

Octokit.auto_paginate = true

# Make sure our working directory is where the script is located.
Dir.chdir(File.dirname(__FILE__))

# Initialize the github api
client = Octokit::Client.new \
  :login    => gh_user,
  :password => gh_pass

# Get all your repos from github's REST API
puts "\n\n----Fetching the metadata of all your github repositories----"

client.repositories.each do |repo| 
    if File.directory? repo.name
        puts "\nFetching #{repo.name}"
        Dir.chdir(repo.name)
		system("mv git .git")
        system("git fetch")
		system("mv .git git")
        Dir.chdir("..")
    else
        puts "\nCloning #{repo.name}"
        system("git clone #{repo.ssh_url} #{repo.name} -n")
		Dir.chdir(repo.name)
		system("mv .git git")
        Dir.chdir("..")
    end
end

# Add all and push
puts "\n\n----Committing and pushing to backup----\n\n"
system("git add -A")
system("git commit -m \"Backup on #{Time.new.inspect}\"")
system("git push origin master")

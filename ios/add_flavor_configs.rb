#!/usr/bin/env ruby
# add_flavor_configs.rb
# Adds Flutter flavor build configurations (Debug-dev, Debug-prod, Release-dev,
# Release-prod, Profile-dev, Profile-prod) to the Xcode project.
#
# Each flavor config duplicates the settings of its base config (Debug, Release, Profile).
# This is required for `flutter build ios --flavor <name>` to work.
#
# Usage: ruby ios/add_flavor_configs.rb
# Requires: gem install xcodeproj

require 'xcodeproj'

project_path = File.join(__dir__, 'Runner.xcodeproj')
project = Xcodeproj::Project.open(project_path)

flavors = ['dev', 'prod']
base_configs = ['Debug', 'Release', 'Profile']

# Check if flavor configs already exist
existing_names = project.build_configurations.map(&:name)
if existing_names.include?('Debug-dev')
  puts "Flavor configurations already exist. Skipping."
  exit 0
end

# For each flavor, duplicate each base configuration
flavors.each do |flavor|
  base_configs.each do |base_name|
    new_name = "#{base_name}-#{flavor}"

    # --- Project-level configuration ---
    base_project_config = project.build_configurations.find { |c| c.name == base_name }
    unless base_project_config
      puts "ERROR: Could not find project-level '#{base_name}' configuration"
      exit 1
    end

    new_project_config = project.add_build_configuration(new_name, base_project_config.type)
    new_project_config.build_settings = base_project_config.build_settings.dup

    # --- Target-level configurations ---
    project.targets.each do |target|
      base_target_config = target.build_configurations.find { |c| c.name == base_name }
      next unless base_target_config

      # add_build_configuration on target
      new_target_config = target.add_build_configuration(new_name, base_target_config.type)
      new_target_config.build_settings = base_target_config.build_settings.dup

      # Preserve the base configuration reference (xcconfig file)
      new_target_config.base_configuration_reference = base_target_config.base_configuration_reference
    end

    puts "Added: #{new_name}"
  end
end

project.save
puts "\nDone! Flavor configurations added to #{project_path}"
puts "Run 'pod install' in the ios/ directory to regenerate Pods configs."

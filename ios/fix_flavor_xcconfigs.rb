#!/usr/bin/env ruby
# fix_flavor_xcconfigs.rb
# After `pod install` generates flavor-specific xcconfig files (e.g.,
# Pods-Runner.debug-dev.xcconfig), this script wires them up as the
# baseConfigurationReference for the corresponding build configurations
# in the Xcode project.
#
# For the Runner target, Flutter's own xcconfigs (Debug.xcconfig, Release.xcconfig)
# already #include the Pods xcconfigs via the Generated.xcconfig mechanism.
# So we keep the Flutter xcconfig as the base and ensure the Pods xcconfigs
# are referenced for the RunnerTests target.
#
# Usage: ruby ios/fix_flavor_xcconfigs.rb  (run AFTER pod install)
# Requires: gem install xcodeproj

require 'xcodeproj'

project_path = File.join(__dir__, 'Runner.xcodeproj')
project = Xcodeproj::Project.open(project_path)

# Map: flavor config name -> which Flutter xcconfig it should use
# Debug-dev and Debug-prod both use Debug.xcconfig
# Release-dev and Release-prod both use Release.xcconfig
# Profile-dev and Profile-prod both use Release.xcconfig (Flutter's convention)
flutter_xcconfig_map = {
  'Debug-dev'   => 'Debug.xcconfig',
  'Debug-prod'  => 'Debug.xcconfig',
  'Release-dev' => 'Release.xcconfig',
  'Release-prod'=> 'Release.xcconfig',
  'Profile-dev' => 'Release.xcconfig',
  'Profile-prod'=> 'Release.xcconfig',
}

# Find the Flutter xcconfig file references in the project
flutter_group = project.main_group.find_subpath('Flutter', false)
unless flutter_group
  puts "ERROR: Could not find 'Flutter' group in project"
  exit 1
end

debug_xcconfig_ref = flutter_group.files.find { |f| f.name == 'Debug.xcconfig' || f.path&.end_with?('Debug.xcconfig') }
release_xcconfig_ref = flutter_group.files.find { |f| f.name == 'Release.xcconfig' || f.path&.end_with?('Release.xcconfig') }

unless debug_xcconfig_ref && release_xcconfig_ref
  puts "ERROR: Could not find Debug.xcconfig or Release.xcconfig in Flutter group"
  puts "  Found files: #{flutter_group.files.map(&:display_name)}"
  exit 1
end

xcconfig_refs = {
  'Debug.xcconfig' => debug_xcconfig_ref,
  'Release.xcconfig' => release_xcconfig_ref,
}

# --- Fix Runner target: point flavor configs at the correct Flutter xcconfig ---
runner_target = project.targets.find { |t| t.name == 'Runner' }
unless runner_target
  puts "ERROR: Could not find Runner target"
  exit 1
end

flutter_xcconfig_map.each do |config_name, xcconfig_name|
  target_config = runner_target.build_configurations.find { |c| c.name == config_name }
  next unless target_config

  ref = xcconfig_refs[xcconfig_name]
  target_config.base_configuration_reference = ref
  puts "Runner/#{config_name} -> #{xcconfig_name}"
end

# --- Fix RunnerTests target: point at Pods-RunnerTests xcconfigs ---
tests_target = project.targets.find { |t| t.name == 'RunnerTests' }
if tests_target
  # Find Pods xcconfig file references for RunnerTests
  # They follow the pattern: Pods-RunnerTests.<config-name-lowercased>.xcconfig
  all_file_refs = project.files

  flutter_xcconfig_map.keys.each do |config_name|
    target_config = tests_target.build_configurations.find { |c| c.name == config_name }
    next unless target_config

    # Pods xcconfig naming: "Pods-RunnerTests.debug-dev.xcconfig"
    pods_xcconfig_name = "Pods-RunnerTests.#{config_name.downcase}.xcconfig"
    pods_ref = all_file_refs.find { |f| f.display_name == pods_xcconfig_name || f.path&.end_with?(pods_xcconfig_name) }

    if pods_ref
      target_config.base_configuration_reference = pods_ref
      puts "RunnerTests/#{config_name} -> #{pods_xcconfig_name}"
    else
      # Fall back to the base type's Pods xcconfig
      base_type = config_name.split('-').first.downcase
      fallback_name = "Pods-RunnerTests.#{base_type}.xcconfig"
      fallback_ref = all_file_refs.find { |f| f.display_name == fallback_name || f.path&.end_with?(fallback_name) }
      if fallback_ref
        target_config.base_configuration_reference = fallback_ref
        puts "RunnerTests/#{config_name} -> #{fallback_name} (fallback)"
      else
        puts "WARNING: No Pods xcconfig found for RunnerTests/#{config_name}"
      end
    end
  end
end

project.save
puts "\nDone! Xcconfig references updated."
puts "You can now run: flutter build ios --simulator --debug --flavor dev"

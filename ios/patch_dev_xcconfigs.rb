#!/usr/bin/env ruby
# patch_dev_xcconfigs.rb
# Run AFTER `pod install` to remove ML Kit framework references from
# dev (simulator) xcconfig files. This prevents linker errors when
# ML Kit pods are excluded from simulator builds via EXCLUDED_ARCHS.
#
# Usage: ruby ios/patch_dev_xcconfigs.rb

require 'pathname'

ios_dir = File.expand_path(__dir__)
pods_support = File.join(ios_dir, 'Pods', 'Target Support Files')

# ML Kit framework names that appear in linker flags and search paths.
# These frameworks don't provide arm64-simulator slices.
mlkit_frameworks = [
  'MLImage',
  'MLKitCommon',
  'MLKitCore',
  'MLKitImageLabelingCommon',
  'MLKitObjectDetection',
  'MLKitObjectDetectionCommon',
  'MLKitObjectDetectionCustom',
  'MLKitVision',
  'MLKitVisionKit',
  'GoogleMLKit',
  'google_mlkit_commons',
  'google_mlkit_object_detection',
]

# Remove ML Kit linker references from xcconfig content.
# We KEEP framework search paths and header search paths so the compiler
# can still find ML Kit headers (needed by GeneratedPluginRegistrant.m).
# We only remove the actual linker flags (-framework "...") from OTHER_LDFLAGS.
def remove_mlkit_refs(content, frameworks)
  # Remove -framework "MLKit..." entries from OTHER_LDFLAGS line only
  frameworks.each do |fw|
    content.gsub!(/-framework\s+"#{Regexp.escape(fw)}"\s*/, '')
  end

  # Clean up double spaces in OTHER_LDFLAGS
  content.gsub!(/  +/, ' ')
  content
end

patched_count = 0

['Pods-Runner', 'Pods-RunnerTests'].each do |pod_target|
  target_dir = File.join(pods_support, pod_target)
  next unless File.directory?(target_dir)

  # Patch both the base xcconfigs (debug, release, profile) and the
  # flavor-specific ones (*-dev). Flutter's xcconfig chain includes the
  # base configs, so those must be patched for simulator builds.
  Dir.glob(File.join(target_dir, '*.xcconfig')).each do |xcconfig_path|
    # Only patch dev-related configs and base configs (which are used by dev flavor)
    basename = File.basename(xcconfig_path)
    next if basename.include?('-prod') # Never patch prod configs

    content = File.read(xcconfig_path)
    original = content.dup
    remove_mlkit_refs(content, mlkit_frameworks)

    if content != original
      File.write(xcconfig_path, content)
      puts "Patched: #{Pathname.new(xcconfig_path).relative_path_from(ios_dir)}"
      patched_count += 1
    else
      puts "No changes: #{Pathname.new(xcconfig_path).relative_path_from(ios_dir)}"
    end
  end
end

if patched_count > 0
  puts "\n✅ Patched #{patched_count} xcconfig file(s). ML Kit references removed from dev configs."
else
  puts "\n⚠️  No files needed patching."
end

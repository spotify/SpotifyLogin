#
# Be sure to run `pod lib lint SpotifyLogin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SpotifyLogin"
  s.version          = "0.1.6"
  s.summary          = "Swift 5 Framework for authenticating with the Spotify API."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                        SpotifyLogin provides a modern Swift 5 Framework for authenticating with the Spotify API.
                       DESC

  s.homepage         = "https://github.com/spotify/SpotifyLogin"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = "Apache 2.0"
  s.author           = { "Roy Marmelstein" => "marmelroy@gmail.com" }
  s.source           = { :git => "https://github.com/spotify/SpotifyLogin.git", :tag => s.version.to_s }
  s.social_media_url   = "http://twitter.com/marmelroy"

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  s.ios.deployment_target = '9.0'
  s.requires_arc = true

  s.source_files = "SpotifyLogin", "Sources", "Sources/Internal"
  s.resources = "SpotifyLogin/Resources/*.*"

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AFNetworking', '~> 2.3'
end
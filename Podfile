platform :ios, '7.0'

xcodeproj 'Fartlek'

pod 'TestFlightSDK', '~> 3.0'
pod 'Bestly'
pod 'AFNetworking', '~> 2.2'
pod 'FlurrySDK', '~> 4.3'
pod 'FontAwesomeKit', '~> 2.1.0'

post_install do |installer|
  installer.project.targets.each do |target|
    puts "#target.name"
  end
end

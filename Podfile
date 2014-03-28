platform :ios, '7.0'

xcodeproj 'Fartlek'

pod 'TestFlightSDK', '~> 3.0'
pod 'Bestly'
pod 'JBChartView', '~> 2.0.1'
pod 'Ono', '~> 0.0'
pod 'AFNetworking', '~> 2.2'
pod 'FlurrySDK', '~> 4.3'

post_install do |installer|
  installer.project.targets.each do |target|
    puts "#target.name"
  end
end

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'SecuXPaymentKitSample' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SecuXPaymentKitSample
  pod 'secux-paymentkit-v2'
  pod 'swiftScan', :git => 'https://github.com/MxABC/swiftScan.git'

  post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
     end
  end
end

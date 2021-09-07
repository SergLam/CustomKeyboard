# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
deployment_target = '12.0'

install! 'cocoapods', :disable_input_output_paths => true, :warn_for_unused_master_specs_repo => false

use_frameworks!
inhibit_all_warnings!

def all_pods
  
  use_frameworks!
  inhibit_all_warnings!
  
  # Networking
  pod 'Moya', '~> 15.0.0'
  pod 'ReachabilitySwift', '~> 5.0.0'
  
end

abstract_target 'App' do
  
  target 'HostingApp' do
    all_pods
  end

  target 'Keyboard' do
    all_pods
  end

  target 'KeyboardFramework' do
    all_pods
  end
  
  post_install do |installer|
    
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = 'NO' # set 'NO' to disable DSYM uploading - usefull for third-party error logging SDK (like Firebase)
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
      end
    end
    
    installer.generated_projects.each do |project|
      project.build_configurations.each do |bc|
        bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = deployment_target
      end
    end
    
  end
  
end

# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'ChatFirebase' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ChatFirebase
  pod 'RxFirebase/Firestore'  # https://github.com/RxSwiftCommunity/RxFirebase
  pod 'RxFirebase/RemoteConfig'
  pod 'RxFirebase/Database'
  pod 'RxFirebase/Storage'
  pod 'RxFirebase/Auth'
  pod 'RxFirebase/Functions'
  
  pod 'SwiftLint' # https://github.com/realm/SwiftLint
  pod 'MBProgressHUD' # https://github.com/jdg/MBProgressHUD
  pod 'YPImagePicker' # https://github.com/Yummypets/YPImagePicker
  pod 'IQKeyboardManagerSwift' # https://github.com/hackiftekhar/IQKeyboardManager
  pod 'Swinject' # https://github.com/Swinject/Swinject
  pod 'Kingfisher' # https://github.com/onevcat/Kingfisher
  pod 'ActiveLabel' # https://github.com/optonaut/ActiveLabel.swift
  pod 'DZNEmptyDataSet' # https://github.com/dzenbot/DZNEmptyDataSet
  pod "RxGesture" # https://github.com/RxSwiftCommunity/RxGesture
  pod 'MessageKit' # https://github.com/MessageKit/MessageKit

  target 'ChatFirebaseTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ChatFirebaseUITests' do
    # Pods for testing
  end
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      if target.name == 'RxSwift'
        target.build_configurations.each do |config|
          if config.name == 'Debug'
            config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
          end
        end
      end
      # target.build_configurations.each do |config|
      #     config.build_settings.delete('SWIFT_VERSION')
      # end
    end
  end

end

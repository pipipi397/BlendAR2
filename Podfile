platform :ios, '15.0'  # iOS 15.0以上をターゲットに設定

target 'BlendAR2' do
  use_frameworks!
  
  # 必要なFirebase関連のライブラリ
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Analytics'
  pod 'GoogleUtilities'
  pod 'GTMSessionFetcher'

  # Pods全体にデプロイメントターゲットを強制
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        # iOSのデプロイメントターゲットを強制的に15.0に設定
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        
        # OTHER_LDFLAGSの重複を防止
        if config.build_settings['OTHER_LDFLAGS'].is_a?(Array)
          config.build_settings['OTHER_LDFLAGS'] = config.build_settings['OTHER_LDFLAGS'].uniq
        elsif config.build_settings['OTHER_LDFLAGS'].is_a?(String)
          config.build_settings['OTHER_LDFLAGS'] = config.build_settings['OTHER_LDFLAGS'].split(' ').uniq.join(' ')
        end
      end
    end
  end
end

Pod::Spec.new do |s|

  s.name = "LostwKit"
  s.version = "1.2.2"
  s.summary = "my personal kit for convience"

  s.description = <<-DESC
    private kit.
  DESC

  s.homepage = "http://101.69.143.198:8082/tz_frontend/ios/lostwkit"
  s.license = "MIT"
  s.author = { "Lostw" => "zzywil@163.com" }

  s.source = { :git => "http://101.69.143.198:8082/tz_frontend/ios/lostwkit.git", :tag => s.version }
  s.source_files = "Source/**/*.{swift}"
  # s.exclude_files = "SwiftyRSA/SwiftyRSA+ObjC.swift"
  # s.framework = "Security"
  s.resource_bundles = {
    'Resource' => ['Resources/*.xcassets'],
  }
  s.resource = 'Resources/*.js'
  s.requires_arc = true
  
  s.swift_version = "5.0"
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.2"
  s.watchos.deployment_target = "2.2"

  s.dependency 'SnapKit', '~> 4.2.0'
  s.dependency 'Alamofire', '~> 4.9.1'
  s.dependency 'SDWebImage', '~> 5.3.0'
  s.dependency 'PromiseKit/CorePromise'
  s.dependency 'WebViewJavascriptBridge'
  s.dependency 'KeychainAccess', '~> 4.1.0'
#  s.subspec "ObjC" do |sp|
#    sp.source_files = "Classes/*/*.{swift}"
#  end
end

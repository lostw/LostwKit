Pod::Spec.new do |s|

  s.name = "LostwKit"
  s.version = "1.0.0"
  s.summary = "private kit"

  s.description = <<-DESC
    private kit.
  DESC

  s.homepage = "https://github.com/TakeScoop/SwiftyRSA"
  s.license = "MIT"
  s.author = { "Lostw" => "zzywil@163.com" }

  s.source = { :git => "https://github.com/TakeScoop/SwiftyRSA.git", :tag => s.version }
  s.source_files = "Classes/**/*.{swift}"
  # s.exclude_files = "SwiftyRSA/SwiftyRSA+ObjC.swift"
  # s.framework = "Security"
  s.resource_bundles = {
    'LostwBundle' => ['Classes/Resource/*.png', 'Classes/Resource/*.js'],
  }
  s.requires_arc = true
  
  s.swift_version = "5.0"
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.2"
  s.watchos.deployment_target = "2.2"

  s.dependency 'SnapKit'
  s.dependency 'Alamofire'
  s.dependency 'AlamofireImage'
  s.dependency 'PromiseKit'
#  s.dependency 'RxSwift',    '~> 4.0'
#  s.dependency 'RxCocoa',    '~> 4.0'

#  s.frameworks = "CommonCrypto"

#  s.subspec "ObjC" do |sp|
#    sp.source_files = "Classes/*/*.{swift}"
#  end
end

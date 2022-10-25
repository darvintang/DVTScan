Pod::Spec.new do |s|
  s.name = 'DVTScan'
  s.version = '2.0.3'
  s.summary = 'DVTScan'

  s.description      = <<-DESC
  TODO:
    利用原生实现的二维码/条码扫描，最基本的控件和接口，提供了一个简单的控制器；
    可以用基本视图自定义预览UI，支持多码扫描并选择。
  DESC

  s.homepage = 'https://github.com/darvintang/DVTScan'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'darvin' => 'darvin@tcoding.cn' }
  s.source = { :git => 'https://github.com/darvintang/DVTScan.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Vision'

  s.dependency 'DVTUIKit', '~> 2.0.1'

  s.swift_version = '5'
  s.requires_arc  = true
end

Pod::Spec.new do |s|
  s.name             = 'ResourcesOCPod'
  s.version          = '0.1.0'
  s.summary          = 'A short description of ResourcesOCPod.'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/Damonvvong/ResourcesOCPod'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Damonvvong' => 'coderonevv@gmail.com' }
  s.source           = { :git => 'https://github.com/Damonvvong/ResourcesOCPod.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'ResourcesOCPod/Classes/**/*'
  #s.resources = 'ResourcesOCPod/image.xcassets'
  s.resource_bundles = {
      'ResourcesOCPod' => ['ResourcesOCPod/image.xcassets']
  }
end


# ResourceManageDemo


- **第一步** 配置 AutoAsset，安装教程可以在 [这里](https://github.com/Damonvvong/AutoAsset) 找到
- **Xcode** 的 **Build Phases** 新加一个脚本

- **第二步** 编写 Podfile 文件，把 Xcode Build Phases 加入

```ruby

source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
inhibit_all_warnings!
platform :ios, '9.0'

target 'ResourceManageDemo' do
pod 'SwiftGen'

script_phase :name => '同步图片', :script => '$PROJECT_DIR/script/AutoAsset $PROJECT_DIR/synchronizeImageFolder $PROJECT_DIR/synchronizeImageFolder_backup $PROJECT_DIR/ResourceManageDemo/Assets.xcassets', :execution_position => :before_compile

script_phase :name => '生成SwiftGen文件', :script => '$PODS_ROOT/SwiftGen/bin/swiftgen  xcassets $PROJECT_DIR/ResourceManageDemo/Assets.xcassets --templatePath $PROJECT_DIR/script/SwiftGenTemplate.stencil --output $PROJECT_DIR/ResourceManageDemo/Assets.swift', :execution_position => :before_compile
end

```

- **第三步** 编译，并编写代码。

- 第一次编译的时候，只会生成 Assets.Swift 文件，需要拖到项目中

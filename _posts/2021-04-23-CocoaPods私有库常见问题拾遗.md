---
layout: post
title: CocoaPods私有库常见问题拾遗
date: 2021-04-23
tags: iOS
---



# CocoaPods 私有库常见问题

## 执行 `pod install` 命令

### [!] Unable to find a specification for MCLib

- 原因：本地没有 `MCLib` 的索引 `spec`。

- 操作：更新 `MCLib` 对应的本地 `repos`。


```
# 更新本地 repo 
pod repo udpate
```


- 备注：本地 `repos` 仓库缓存目录：`~/.cocoapods/repos/`。

* * *

### [!] Unable to find a specification for `FMDB` depended upon by `MCLib`

- 原因：`Podfile` 在私有库后面配置了 `source`，没有考虑到私有库 `A` 依赖的私有库 `B`，而私有库 `B` 依赖 `FMDB`， 在设置的 `source` 中找不到 `FMDB`。


```
# Podfile 
 pod 'A' , '0.0.1' , :source => 'git@10.2.250.21:MCLib/specRepo_iOS.git'
```
 

- 操作：正确做法是在 `Podfile` 头部配置多个 `source`。

 
```
source 'git@10.2.250.21:MCLib/specRepo_iOS.git'
source 'https://github.com/CocoaPods/Specs.git'
```
 

* * *

### [!] CocoaPods could not find compatible versions for pod “MCStatistics”

- 描述：


```
MacBook-Pro:$ pod install
Analyzing dependencies
Pre-downloading: `MCStatistics` from `https://gitlab.com/xxx/MCStatistics_framework.git`
[!] CocoaPods could not find compatible versions for pod "MCStatistics":
 In Podfile:
 MCStatistics (from `https://gitlab.com/xxxx/MCStatistics_framework.git`)

Specs satisfying the `MCStatistics (from `https://gitlab.com/xxxxxxx/MCStatistics_framework.git`)` dependency were found, but they required a higher minimum deployment target.
```
 
- 原因：`Podfile` 配置的最低支持平台低于 `spec` 配置的最低平台 `8.0`。

`Podfile` 配置最低平台支持 `7.0` 。


```
platform :ios, '7.0'
pod 'MCPrivateNetworking', :git => 'https://gitlab.com/xxxxx/framwwork.git'
```
 

`spec` 配置最低平台支持 `8.0`。


```
s.platform = :ios, '8.0' # 平台及支持的最低版本
```


* * *

* * *

## 执行 `pod repo push` 命令

推送 `spec` 文件时。

### CocoaPods 私有库，静态 Framework 验证失败


```
The following build commands failed:
 CompileC /Users/mengyueping/Library/Developer/Xcode/DerivedData/App-fbdglhmiocesdxeuqlwfuuhbmtht/Build/Intermediates.noindex/Pods.build/Release-iphonesimulator/MCLib.build/Objects-normal/i386/openssl_wrapper.o MCLib/MCLib/Lib/Util/openssl_wrapper.m normal i386 objective-c com.apple.compilers.llvm.clang.1_0.compiler
 (1 failure)
 Testing with `xcodebuild`. 
 -> MCLib (0.0.1)
 - ERROR | [iOS] xcodebuild: Returned an unsuccessful exit code.
```
 

指定私有库的源，验证 `.podspec` 文件时，出现私有库找不到。

* * *

### fatal error: could not build module ‘xxxxx’

- 或者： Include of non-modular header inside framework module

- 原因：私有库的 `.h` 文件中引入了依赖的源码库的 `.h` 文件，导致根据的私有库的 `module.modulemap` 找不到该头文件，导致错误。（比如：`MCFoundtion` 库某个公开的头文件中引用了 `AFNetworking` 类的头文件。分装库代码的时候应该尽量避免公开的头文件中，引入第三方依赖开源库的头文件。）

- 解决：设置 `BuildSetting` 的 `Allow Non-modular Includes In Framework Modules` 为 `YES`

```
spec.user_target_xcconfig = { 'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES' }。

# lint 命令只剩下 warning。

# user_target_xcconfig 和 pod_target_xcconfig 的区别:
# user_target_xcconfig 是对于编译工程中所有 pod 的设置，
# 而 pod_target_xcconfig 只是针对当前 pod 的。
# 所以如果多个 pod 的 podspec 中对 user_target_xcconfig 同一个值进行了设置，那么就可能存在冲突问题。
# 但因为 CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES 在 pod_target_xcconfig 不起作用，只能按现在的配置来处理。
```
 

* * *

`Cloning into ‘/var/folders/rg/f1ycrs553dq2z2dq7mt0mbh80000gn/T/d20160921-12602-1bx4f8v’… remote: Not Found fatal: repository ‘http://192.168.110.114/xxxxxx.git/’ not found`

- 原因：`pod spec lint` 命令，校验 `pod` 的代码和配置时是从 `git` 上拉取响应版本（`Tag`）的代码进行编译；没有创建 `git` 代码仓库，报错。

* * *

`> Cloning into ‘/var/folders/rg/f1ycrs553dq2z2dq7mt0mbh80000gn/T/d20160921-12686-1o6vj1q’… fatal: Remote branch 0.1.0 not found in upstream origin`

- 原因：没有在 `git` 上增加对应的 `tag` 值，报错。 

* * *

### [!] Found multiple specifications

- 原因：将私有仓库拉到本地时可能会存在两个。 

- 解释：因为 `git` 存在两个地址，分别是 `git@` 和 `http/https`，所以有时候可能会在本地 `repos` 下出现两个基于同一个 `git` 的仓库，仓库名字不同。因为一开始 `lint` 的时候是指定了仓库名的，所以能通过，但 `pod repo push` 的时候虽然指定了 `push` 的仓库名，但因为没有指定校验的仓库名，一旦你的 `pod` 依赖了私有仓库中的某个 `pod`，校验时会出现类似 `[!] Found multiple specifications xxxxLibrary` 的错误。此时需要删除掉一个私有仓库，然后重新 `push` 才行。 

- 备注：这里需要明白 `pod spec lint` 的时候，可以配置 `--sources`。而 `pod repo push` 的时候，是直接使用的本地仓库名。有可能 `--sources` 指定的是 `http/https` ，而本地 `repo` 仓库是使用的 `git@` 拉取的。


```
pod spec lint --verbose --use-libraries --allow-warnings --sources='私有仓库repo地址,https://github.com/CocoaPods/Specs'

pod repo push MCRepo MCAppKit.podspec --verbose --use-libraries --allow-warnings
```
 

* * *

### pod Libraries should not include the extension

- 原因：工程中导入了第三方 `SDK` ，包含有二进制文件，没有在 `spec` 文件中配置。

- 解决：需要配置一下路径，保证 `push repo` 的时候，不丢失二进制文件：


```
s.vendored_libraries = ['Class/SobotSDK/SobotLib/libSobotLib.a']
```

* * *

### 编译时，找不到宏定义

- 原因：宏定义可能和环境有关。根据 `DEBUG` 和 `RELEASE` 定义了不同的宏。eg：


```
#ifdef DEBUG
 #define kAppKey @“123456789”
#endif
#ifdef RELEASE
 #define kAppKey @“987654321”
#endif
```


- 解决：

编译时，找不到宏定义 `kAppKey` ，需要设置查看：


```
Project -> Build Settings -> Preprocessor Macros -> 
Debug DEBUG=1
Release RELEASE
```

对应 Spec 文件设置：

```
s.xcconfig = {
"GCC_PREPROCESSOR_DEFINITIONS" => "RELEASE COCOAPODS=1"
 }
```

* * *

### Shell Script Invocation Error Group

- 错误信息：

```
Shell Script Invocation Error Group

sent 31754831 bytes received 54674 bytes 21206336.67 bytes/sec
total size is 36763600 speedup is 1.16
/* com.apple.actool.errors */
: error: There are multiple stickers icon set or app icon set instances named "AppIcon".
/* com.apple.actool.compilation-results */
/Users/mengyueping/Library/Developer/Xcode/DerivedData/Example-fdeuhzzwrdwyjrfsdeusamwbippd/Build/Products/Debug-iphonesimulator/Example.app/Assets.car
/Users/mengyueping/Library/Developer/Xcode/DerivedData/Example-fdeuhzzwrdwyjrfsdeusamwbippd/Build/Intermediates.noindex/Example.build/Debug-iphonesimulator/Example.build/assetcatalog_generated_info_cocoapods.plist

Command /bin/sh failed with exit code 1
```

- 原因：`Pod` 资源拷贝脚本运行错误。不同 `Bundle` 有同名资源。有多个 `AppIcon` 。

在自己工程 `Build Phases -> Copy Pods Resources` 中，可以看到配置的资源拷贝脚本：


```
"${SRCROOT}/Pods/Target Support Files/Pods-Example/Pods-Example-resources.sh"
```


这个脚本是 `pod` 自己生成的，咱们也可以在物理文件夹下找到该脚本。

- 解决：可以通过去除这个脚本来解决冲突，但是这样会丢失资源文件。所以最终解决方法是，应该去除重名的资源文件 `AppIcon` 。

### duplicate symbol

- 错误信息：

```
duplicate symbol _OBJC_IVAR_$_ViewController._lastIndex in:
 /Users/mengyueping/Library/Developer/Xcode/DerivedData/Example-fdeuhzzwrdwyjrfsdeusamwbippd/Build/Products/Debug-iphonesimulator/libMain.a(ViewController.o)
```

- 原因：`duplicate symbol` 重复符号。原因一，有可能是重复类。原因二，也有可能是在某个文件中引入了 `.m` 文件。 eg：`#import "ViewController.m"` 。

* * *

### Unable to run command ‘StripNIB TableViewListCell.nib’ - this target might include its own product.

- 原因：`xib` 文件没有指定路径，`pod` 的时候不会下载 `xib`。`xib` 文件算是资源文件的，需要另外添加 `s.resource` 引入。

- 解决：

```
s.source_files = "pod/classes/**/*.{h,m}"
s.resource = "pod/classes/TestViewController.xib"

# 或者把 xib 拷贝到 bundle 中，直接指定资源文件路径为 bundle 。

s.resources = ['*.bundle', '*.strings']
```

* * *

### [!] Unable to find a specification for `BaseSDK (= 1.0.2)` depended upon by `MyProject`

- 描述：

```
Analyzing dependencies
Fetching podspec for `MyProject` from `../`
[!] Unable to find a specification for `BaseSDK (= 1.0.2)` depended upon by `MyProject`
```

- 原因：没有配置私有库的索引库地址。

- 解决：
 
```
source 'git@10.2.24.2:MengCode/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'
```

* * *

### libLWApiSDK.a(LWApiRequest.o)’ does not contain bitcode.

- 描述：


```
ld: '/Users/mengyueping/MCModule/MCUIKit/MCUIKitCode/Example/Pods/UMengUShare/UShareSDK/SocialLibraries/LaiWang/libLWApiSDK.a(LWApiRequest.o)' does not contain bitcode. You must rebuild it with bitcode enabled (Xcode setting ENABLE_BITCODE), obtain an updated library from the vendor, or disable bitcode for this target. file '/Users/mengyueping/MCModule/MCUIKit/MCUIKitCode/Example/Pods/UMengUShare/UShareSDK/SocialLibraries/LaiWang/libLWApiSDK.a' for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

- 解决：

```
Build Settings -> Enable Bitcode -> NO
```


### Could not build module ‘MCFoundation’

- 描述：

```
Could not build module 'MCFoundation'

- ERROR | xcodebuild: MCFoundationLib/MCFoundation/MCFoundation.framework/Headers/MCRefreshBackNormalFooter.h:9:9: error: include of non-modular header inside framework module 'MCFoundation.MCRefreshBackNormalFooter': 'Headers/Public/MJRefresh/MJRefreshBackNormalFooter.h' [-Werror,-Wnon-modular-include-in-framework-module]

- NOTE | xcodebuild: Headers/Public/MCKit/MCSavaDataManager.h:11:9: fatal error: could not build module 'MCFoundation'
```


- 原因：在头文件中，引入了第三方 `pod` 管理的库的头文件。


```
s.user_target_xcconfig = { 
"CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES" => "YES"
}
```
 
设置后，`push spec` 会出现：


```
[!] Smart quotes were detected and ignored in your Podfile. To avoid issues in the future, you should not use TextEdit for editing it. If you are not using TextEdit, you should turn off smart quotes in your editor of choice.

[!] The `MC [Debug]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC/Pods-MC.debug.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.

[!] The `MC [Gamma]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC/Pods-MC.gamma.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.

[!] The `MC [PreRelease]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC/Pods-MC.prerelease.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.

[!] The `MC [Release]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC/Pods-MC.release.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.

[!] The `MC-Test [Debug]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC-Test/Pods-MC-Test.debug.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.

[!] The `MC-Test [Gamma]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC-Test/Pods-MC-Test.gamma.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.

[!] The `MC-Test [PreRelease]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC-Test/Pods-MC-Test.prerelease.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.

[!] The `MC-Test [Release]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC-Test/Pods-MC-Test.release.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.

[!] The `MC-Release [Debug]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC-Release/Pods-MC-Release.debug.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.

[!] The `MC-Release [Gamma]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC-Release/Pods-MC-Release.gamma.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.

[!] The `MC-Release [PreRelease]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC-Release/Pods-MC-Release.prerelease.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.

[!] The `MC-Release [Release]` target overrides the `CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES` build setting defined in `Pods/Target Support Files/Pods-MC-Release/Pods-MC-Release.release.xcconfig'. This can lead to problems with the CocoaPods installation
 - Use the `$(inherited)` flag, or
 - Remove the build settings from the target.
```

* * *

### The ‘Pods’ target has transitive dependencies

- 原因：如果私有库添加了静态库或者 `dependency` 用了静态库。

- 解决：那么执行 `pod spec lint` 或者 `pod repo push` 时候需要加上 `—user-libraries` 选项。否则会出现 `The 'Pods' target has transitive dependencies` 错误。

* * *

* * *

## 执行 `pod spec lint` 命令

> `pod lib lint` 是只从本地验证你的 `pod` 能否通过验证。
> 
> `pod spec lint` 是从本地和远程验证你的 `pod` 能否通过验证。

在私有库引用了私有库的情况下，在验证和推送私有库的情况下都要加上所有的资源地址，不然 `pod` 会默认从官方 `repo` 查询。  
使用 `pod spec lint` 去验证私有库能否通过验证时，应该要添加 `--sources` 选项，不然会出现找不到 `repo` 的错误。

```
# 配置 `--sources` 下载源。

pod spec lint --sources='私有仓库repo地址,https://github.com/CocoaPods/Specs'
pod repo push 本地repo名 podspec名 --sources='私有仓库repo地址,https://github.com/CocoaPods/Specs'

pod lib lint MCCommon.podspec --sources='http://10.2.250.21/MC/MCPrivateSourceCodeSpecRepo.git,https://github.com/CocoaPods/Specs.git' 

pod spec lint MCCommon.podspec --sources='http://10.2.222.22/MC/MCPrivateSourceCodeSpecRepo.git,https://github.com/CocoaPods/Specs.git'
```

* * *

* * *

## `Podfile` 文件

### `inhibit_all_warnings!`

屏蔽 `cocoapods` 库里面的所有警告。这个特性也能在子 `target` 里面定义。

如果你想屏蔽某 `pod` 库里面的警告也是可以的:


```
pod 'SSZipArchive', :inhibit_warnings => true
```

* * *

### 引用本地库

在 `Podfile` 中配置引用本地库文件：


```
pod '库名', :path => '本地路径'
```


这样在通常的修改代码中是不需要执行 `pod update` 的。但是对于如果修改了目录结构（添加、删除或者移动文件文件）或者是修改了 `Podspec` 文件的配置的话，最好是运行一下 `pod update` 的命令。普通修改代码的情况下就不需要运行 `pod update` 命令。


```
pod 'iOS-Test', :path => '../iOS-Test’
```


* * *

* * *

## `spec` 文件

### 包含有 `MRC` 文件类

- 方法一：

```
s.requires_arc = false
s.source_files = "MCFoundation/**/*.{h,m}"
s.requires_arc = "MCFoundation/CommonComponent/**/*.{h,m}"
```
 

- 方法二：`subspec`


```
Pod::Spec.new do |s|

s.name = "MCFoundation"
s.version ="0.1.3.3"
s.summary = "源码仓库."
s.description = <<-DESC
封装了一些基础的工具
DESC
s.homepage = "http://10.2.222.22/MC"
s.license = { :type => "MIT", :file => "LICENSE" }
s.author = { "xxx" => "xxx@xxx.com" }
s.ios.deployment_target = "8.0"
s.source = { :git => 'git@10.2.22.22:MCModuleiOS/MCFoundationCode.git', :tag => s.version}

s.default_subspec = 'MCFoundationARC'

non_arc_files = 'MCFoundation/MRC/*.{h,m}'

s.subspec 'MCFoundationARC' do |arc|
 arc.requires_arc = true
 arc.source_files = "MCFoundation/CommonComponent/**/*.{h,m}"
 arc.exclude_files = non_arc_files 
end

s.subspec 'MCFoundationNonARC' do |non_arc|
 non_arc.requires_arc = false
 non_arc.source_files = non_arc_files
 non_arc.dependency 'MCFoundation/MCFoundationARC'
end

s.dependency 'FMDB'
s.dependency 'MJRefresh'

end
```

* * *

### 引用自己或第三方的 `framework` 或 `.a` 文件时

在 `podsepc` 中应该这样写:


```
s.ios.vendored_frameworks = "xxx/**/*.framework"
s.ios.vendored_libraries = "xxx/**/*.a”
```


* * *

### 资源文件

- 把资源文件放在 `bundle` 中，`spec` 文件需要配置：


```
spec.resource = "Resources/MYLibrary.bundle"

spec.resource_bundles = {
'MyLibrary' => ['Resources/*.png'],
'OtherResources' => ['OtherResources/*.png']
}
```


- 也可以这样写，但是这些资源会在打包的时候直接拷贝的 `app` 中，这样说不定会和其它资源产生命名冲突：


```
spec.resources = ["Images/*.png", "Sounds/*"]
```


* * *

### 配置执行脚本

可以在编译的某个时机，来配置要运行的脚本。

```
# :execution_position 选项有 [:before_compile, :after_compile, :any]

s.script_phase = { :name => "Script Name", :script => "echo 'Hello World'", :execution_position => :any , :shell_path => "/bin/sh"}
```

* * *

### `subspec`

为了让自己的 `Pod` 被导入时显示出良好的文件层划分，`subspec` 是必须的。  
若 `subspec` 要依赖其它的 `subspec` ，则 `subspec` 的 `dependency` 后面接的不是目录路径，而是 `specA/specB` 这种 `spec` 关系。






# 本文转自:http://www.mengyueping.com/2018/08/16/iOS_CocoaPods_03/


---
layout: post
title: xcconfig的使用与xcode环境变量
date: 2021-05-07
tags: iOS
---




# xcconfig的使用与xcode环境变量

在正式使用xcconfig之前，还是得先把这几个概念给区分一下。什么是workspace，什么是project，什么是target。下面一张图简单说明：

![](/images/posts/iOS/xcconfig/1293297-1a55808c63b6d254.webp)

- workspace，顾名思义就是我们的工作区。一个workspace可以包含多个project以及一些其它文件。workspace也可以把多可以project组织起来。
- 一个project会包含属于这个项目的所有文件，资源，以及生成一个或者多个软件产品的信息。
- 一个project会包含一个或者多个 target，而每一个 target都对应一个products，也就是最终产生的.app。
- 一个targets可以有多个configuration（如我们平常用到的debug和release，当然我们还可以自己添加），每个configuration就会有对应的build settings。每次build都是在一个configuration下build的。
- build setting 中包含了 product 生成过程中所需的参数信息。project的build settings会对于整个project 中的所有targets生效，而target的build settings是重写了project的build settings，重写的配置以target为准。

那么，什么又是scheme呢？scheme就相当于一个组织者。在build的时候，schema会指定一个target和configuration，这样就能保证在build的时候configuration的唯一性，就能产生一个特定的product。

OK。理清了这些环境变量后，就可以来介绍一下xcconfig了。  
在项目中使用了cocoapods的都会发现，在pod项目中有.xcconfig这样的文件，一般有多少个configuration就会有多少个.xcconfig这样的文件。一般工程中就分为debug和release两个。这里的.xcconfig文件就是通过文本方式指定build settings的一种形式。

所以我们也可以在工程中通过创建xcconfig来指定build settings。这样能够更加方面管理和修改。

下面我在一个demo工程中创建了几个xcconfig。

![](/images/posts/iOS/xcconfig/1293297-90b863682f33401e.webp)


其中common为通用configuration。

![](/images/posts/iOS/xcconfig/1293297-d0fc013b5a6e9730.webp)

所有环境相同的settings可以写在这里。然后你就可以在里面去添加任意键值对了。下面是`settings.release.xcconfig`的一个示例。

```
// settings.release.xcconfig
#include "settings.common.xcconfig"
#include "Pods/Target Support Files/Pods-TTLivenessDetection_Example/Pods-TTLivenessDetection_Example.release.xcconfig"
ONLY_ACTIVE_ARCH = NO
ENABLE_BITCODE = YES
test = 123
```

然后在project-\>info中去设置。

![](/images/posts/iOS/xcconfig/1293297-cf1ac2fc9ef5e5f5.webp)

这里有个坑就是自定义配置后会导致cocoapods无法使用，这里需要在相应的xcconfig里面导入相应的pod的xcconfig

```
#include "Pods/Target Support Files/Pods-TTLivenessDetection_Example/Pods-
TTLivenessDetection_Example.release.xcconfig"
```

如果还报这种错

```
[!] The `TTLivenessDetection_Example [Debug]` target overrides the 
`HEADER_SEARCH_PATHS` build setting defined in `Pods/Target Support 
Files/Pods-TTLivenessDetection_Example/Pods-
TTLivenessDetection_Example.debug.xcconfig'. This can lead to problems with the CocoaPods installation
    - Use the `$(inherited)` flag, or
    - Remove the build settings from the target.
```

按照它说的把`HEADER_SEARCH_PATHS`改为`$(inherited)`就可以了。

另外就是这里有个继承关系，打开levels可以查看

  

![](/images/posts/iOS/xcconfig/1293297-c3f3005ab8c0d992.webp)

其中继承关系如下：  
Target configuration-\>Target xcconfig-\>Project configuration-\>Project xcconfig。

也就是说如果是单一的配置，继承级低的会覆盖继承等级高的，而像$()这样的会进行叠加。


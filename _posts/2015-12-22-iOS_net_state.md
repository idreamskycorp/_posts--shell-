---
layout: post
title: iOS获取设备的网络状态(已适配iOS13,iOS14无变化)
date: 2015-12-22
tags: iOS
---
[登录](/sign_in)[注册](/sign_up)[写文章](/writer)

[首页](/)[下载APP](/apps?utm_medium=desktop&utm_source=navbar-apps)

# iOS获取设备的网络状态(已适配iOS13,iOS14无变化)

[神SKY](/u/3ea97312adbd)关注赞赏支持

# iOS获取设备的网络状态(已适配iOS13,iOS14无变化)

# 前言

小编最近在项目中遇到了一个问题，除刘海屏以外的iOS设备可以正常的搜索到硬件设备，但是刘海屏就不行。因此，小编花了一点时间研究了一下iOS设备获取当前设备的网络状态。

# 实现

因为iOS的系统是封闭的，所以是没有直接的APi去获取当前的网络状态。但是道高一尺，魔高一尺。开发者总会有办法获取自己想要的东西。

### 1.网络状态获取

###### 获取当前的网络类型

获取当前的网络类型是通过获取状态栏，然后遍历状态栏的视图完成的。  
先导入头文件，如下：

```
#import "AppDelegate.h"
```

实现方法如下：

```
+ (NSString *)getNetworkType
{
    UIApplication *app = [UIApplication sharedApplication];
    id statusBar = nil;
// 判断是否是iOS 13
    NSString *network = @"";
    if (@available(iOS 13.0, *)) {
        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
            UIView *localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
            if ([localStatusBar respondsToSelector:@selector(statusBar)]) {
                statusBar = [localStatusBar performSelector:@selector(statusBar)];
            }
        }
#pragma clang diagnostic pop
        
        if (statusBar) {
// UIStatusBarDataCellularEntry
            id currentData = [[statusBar valueForKeyPath:@"_statusBar"] valueForKeyPath:@"currentData"];
            id _wifiEntry = [currentData valueForKeyPath:@"wifiEntry"];
            id _cellularEntry = [currentData valueForKeyPath:@"cellularEntry"];
            if (_wifiEntry && [[_wifiEntry valueForKeyPath:@"isEnabled"] boolValue]) {
// If wifiEntry is enabled, is WiFi.
                network = @"WIFI";
            } else if (_cellularEntry && [[_cellularEntry valueForKeyPath:@"isEnabled"] boolValue]) {
                NSNumber *type = [_cellularEntry valueForKeyPath:@"type"];
                if (type) {
                    switch (type.integerValue) {
                        case 0:
// 无sim卡
                            network = @"NONE";
                            break;
                        case 1:
                            network = @"1G";
                            break;
                        case 4:
                            network = @"3G";
                            break;
                        case 5:
                            network = @"4G";
                            break;
                        default:
// 默认WWAN类型
                            network = @"WWAN";
                            break;
                            }
                        }
                    }
                }
    }else {
        statusBar = [app valueForKeyPath:@"statusBar"];
        
        if ([[[self alloc]init]isLiuHaiScreen]) {
// 刘海屏
                id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
                UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
                NSArray *subviews = [[foregroundView subviews][2] subviews];
                
                if (subviews.count == 0) {
// iOS 12
                    id currentData = [statusBarView valueForKeyPath:@"currentData"];
                    id wifiEntry = [currentData valueForKey:@"wifiEntry"];
                    if ([[wifiEntry valueForKey:@"_enabled"] boolValue]) {
                        network = @"WIFI";
                    }else {
// 卡1:
                        id cellularEntry = [currentData valueForKey:@"cellularEntry"];
// 卡2:
                        id secondaryCellularEntry = [currentData valueForKey:@"secondaryCellularEntry"];

                        if (([[cellularEntry valueForKey:@"_enabled"] boolValue]|[[secondaryCellularEntry valueForKey:@"_enabled"] boolValue]) == NO) {
// 无卡情况
                            network = @"NONE";
                        }else {
// 判断卡1还是卡2
                            BOOL isCardOne = [[cellularEntry valueForKey:@"_enabled"] boolValue];
                            int networkType = isCardOne ? [[cellularEntry valueForKey:@"type"] intValue] : [[secondaryCellularEntry valueForKey:@"type"] intValue];
                            switch (networkType) {
                                    case 0://无服务
                                    network = [NSString stringWithFormat:@"%@-%@", isCardOne ? @"Card 1" : @"Card 2", @"NONE"];
                                    break;
                                    case 3:
                                    network = [NSString stringWithFormat:@"%@-%@", isCardOne ? @"Card 1" : @"Card 2", @"2G/E"];
                                    break;
                                    case 4:
                                    network = [NSString stringWithFormat:@"%@-%@", isCardOne ? @"Card 1" : @"Card 2", @"3G"];
                                    break;
                                    case 5:
                                    network = [NSString stringWithFormat:@"%@-%@", isCardOne ? @"Card 1" : @"Card 2", @"4G"];
                                    break;
                                default:
                                    break;
                            }
                            
                        }
                    }
                
                }else {
                    
                    for (id subview in subviews) {
                        if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                            network = @"WIFI";
                        }else if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarStringView")]) {
                            network = [subview valueForKeyPath:@"originalText"];
                        }
                    }
                }
                
            }else {
// 非刘海屏
                UIView *foregroundView = [statusBar valueForKeyPath:@"foregroundView"];
                NSArray *subviews = [foregroundView subviews];
                
                for (id subview in subviews) {
                    if ([subview isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
                        int networkType = [[subview valueForKeyPath:@"dataNetworkType"] intValue];
                        switch (networkType) {
                            case 0:
                                network = @"NONE";
                                break;
                            case 1:
                                network = @"2G";
                                break;
                            case 2:
                                network = @"3G";
                                break;
                            case 3:
                                network = @"4G";
                                break;
                            case 5:
                                network = @"WIFI";
                                break;
                            default:
                                break;
                        }
                    }
                }
            }
    }

    if ([network isEqualToString:@""]) {
        network = @"NO DISPLAY";
    }
    return network;
}
```

###### 获取当前的Wifi信息

获取当前的Wifi信息需要借助系统的SystemConfiguration这个库。  
先导入头文件，如下：

```
#import <SystemConfiguration/CaptiveNetwork.h>
```

实现方法如下：

```
#pragma mark 获取Wifi信息
+ (id)fetchSSIDInfo
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count]) {
            break;
        }
    }
    return info;
}
#pragma mark 获取WIFI名字
+ (NSString *)getWifiSSID
{
    return (NSString *)[self fetchSSIDInfo][@"SSID"];
}
#pragma mark 获取WIFI的MAC地址
+ (NSString *)getWifiBSSID
{
    return (NSString *)[self fetchSSIDInfo][@"BSSID"];
}
```

###### 获取当前的Wifi信号强度

获取信号强度与获取网络状态有点类似，通过遍历状态栏，从而获取WIFI图标的信号强度。在获取前需注意当前状态是否为WIFI。如下：

```
+ (int)getWifiSignalStrength{
    
    int signalStrength = 0;
// 判断类型是否为WIFI
    if ([[self getNetworkType]isEqualToString:@"WIFI"]) {
// 判断是否为iOS 13
        if (@available(iOS 13.0, *)) {
            UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
             
            id statusBar = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
                UIView *localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
                if ([localStatusBar respondsToSelector:@selector(statusBar)]) {
                    statusBar = [localStatusBar performSelector:@selector(statusBar)];
                }
            }
#pragma clang diagnostic pop
            if (statusBar) {
                id currentData = [[statusBar valueForKeyPath:@"_statusBar"] valueForKeyPath:@"currentData"];
                id wifiEntry = [currentData valueForKeyPath:@"wifiEntry"];
                if ([wifiEntry isKindOfClass:NSClassFromString(@"_UIStatusBarDataIntegerEntry")]) {
// 层级：_UIStatusBarDataNetworkEntry、_UIStatusBarDataIntegerEntry、_UIStatusBarDataEntry
                    
                    signalStrength = [[wifiEntry valueForKey:@"displayValue"] intValue];
                }
            }
        }else {
            UIApplication *app = [UIApplication sharedApplication];
            id statusBar = [app valueForKey:@"statusBar"];
            if ([[[self alloc]init]isLiuHaiScreen]) {
// 刘海屏
                id statusBarView = [statusBar valueForKeyPath:@"statusBar"];
                UIView *foregroundView = [statusBarView valueForKeyPath:@"foregroundView"];
                NSArray *subviews = [[foregroundView subviews][2] subviews];
                       
                if (subviews.count == 0) {
// iOS 12
                    id currentData = [statusBarView valueForKeyPath:@"currentData"];
                    id wifiEntry = [currentData valueForKey:@"wifiEntry"];
                    signalStrength = [[wifiEntry valueForKey:@"displayValue"] intValue];
// dBm
// int rawValue = [[wifiEntry valueForKey:@"rawValue"] intValue];
                }else {
                    for (id subview in subviews) {
                        if ([subview isKindOfClass:NSClassFromString(@"_UIStatusBarWifiSignalView")]) {
                            signalStrength = [[subview valueForKey:@"_numberOfActiveBars"] intValue];
                        }
                    }
                }
            }else {
// 非刘海屏
                UIView *foregroundView = [statusBar valueForKey:@"foregroundView"];
                     
                NSArray *subviews = [foregroundView subviews];
                NSString *dataNetworkItemView = nil;
                       
                for (id subview in subviews) {
                    if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
                        dataNetworkItemView = subview;
                        break;
                    }
                }
                       
                signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
                        
                return signalStrength;
            }
        }
    }
    return signalStrength;
}
```

### 2.Reachability的使用

下载开源类Reachability，然后根据文档使用即可（该类把移动网络统称为WWAN）：

```
+ (NSString *)getNetworkTypeByReachability
{
    NSString *network = @"";
    switch ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]) {
        case NotReachable:
            network = @"NONE";
            break;
        case ReachableViaWiFi:
            network = @"WIFI";
            break;
        case ReachableViaWWAN:
            network = @"WWAN";
            break;
        default:
            break;
    }
    if ([network isEqualToString:@""]) {
        network = @"NO DISPLAY";
    }
    return network;
}
```

上次发布了这篇文章之后，有人问我，怎么才能获取设备的IP地址呢？在这里，小编附上获取iP地址的方法。  
先导入头文件，如下：

```
#import <ifaddrs.h>
#import <arpa/inet.h>
```

实现方法，如下：

```
#pragma mark 获取设备IP地址
+ (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // 检索当前接口,在成功时,返回0
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // 循环链表的接口
        temp_addr = interfaces;
        while(temp_addr != NULL) {
// 开热点时本机的IP地址
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"bridge100"]
                    ) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // 检查接口是否en0 wifi连接在iPhone上
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // 得到NSString从C字符串
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // 释放内存
    freeifaddrs(interfaces);
    return address;
}
```

### 3.iOS 12下的补充

在iOS 12下xcode需要打开权限才可以正常操作，如下：

  

 ![]()

### 4.iOS 13下的补充

在iOS 13下xcode需要打开权限才可以正常操作，如下：

  

 ![]()

 ![]()

  

并且，在iOS 13下，若要获取SSID和BSSID，需要添加定位权限

  

 ![]()

```
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (@available(iOS 13.0, *)) {
// 如果是iOS13 未开启地理位置权限 需要提示一下
           if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
               self.locationManager = [[CLLocationManager alloc] init];
               [self.locationManager requestWhenInUseAuthorization];
           }
       }
}
```

> 到这里为止，这篇文章就结束了。在这里提醒一下各位看官，横屏时请注意不要把状态栏去掉。有说明不足的地方欢迎评论，这里附上Demo下载地址：[Demo](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2FshenSKY%2FGetNetwork.git)。最后，希望这篇文章对各位看官们有所帮助。对支持小编的看官们表示感谢。

### 推荐阅读[更多精彩内容](/)

- 

[光](/p/3b3ed5a8bb46)

我来了 一个人 奔跑着 在晶莹美丽的清晨曦光里 你来了 两个人 手牵着 在刺眼苍白的晌午浓光里 他来了 一个人 等...

[默默磨墨s](/u/1b5510bf9f43)阅读 53评论 0赞 1

- 

[Nodejs: 不借助框架，如何最简单有效的实现异步编程 [简约有理]](/p/54d7bfe5eb2e)

本文探讨利用原生机制，来最快速简单的实现异步事件流。这个傻瓜化的宗旨，是来自要面对的很实际的问题: 为了说明所采用...

[Tulayang](/u/eefc22646652)阅读 2,737评论 6赞 9

- 

[相见时难别亦难，看你存在真麻烦，看你离开真不愿](/p/36b2be56f229)

我们很久没有这么长时间在一起了吧，从7月中末开始到9月将要初结，时间过得真快，你我又要面对不知多久的分别。 从各自...

[GZ徐](/u/2f98737c61d2)阅读 167评论 5赞 1

- 

[秋色十里 不如你回身一按？](/p/b5f2f125b447)

风轻云淡的天空，随处可见的风景，快拿起手机，用镜头捕捉你身边的秋天吧！

[努比亚智能手机](/u/7a51172747d6)阅读 112评论 0赞 1

- 

[『原创手画』你的新娘，我的知己。](/p/e36052e64b40)

囍: 无论什么样的女人，在穿上白纱的那一刻，都显得无比圣洁和美丽，这大概就是婚纱的魅力。 谢谢阅览！ 喜欢就点个赞...

[田螺姑娘Tina](/u/5dff3a55a85e)阅读 630评论 10赞 33

评论57

赞35

抽奖
 ![reward](data:image/png;base64,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)

35赞36赞

赞赏

更多好文


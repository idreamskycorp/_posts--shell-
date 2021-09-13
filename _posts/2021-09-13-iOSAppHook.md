---
layout: post
title: iOS AppHook
date: 2021-09-13
tags: iOS
---
```
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (AppHook)

void ct_hookMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector);
void ct_hookClassMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector);
void ct_addMethod(Class originalClass,Class swizzledClass, SEL swizzledSelector);

@end

NS_ASSUME_NONNULL_END

@implementation NSObject (AppHook)

void ct_hookMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    if(originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

void ct_hookClassMethod(Class originalClass, SEL originalSelector, Class swizzledClass, SEL swizzledSelector) {
    Method originalMethod = class_getClassMethod(originalClass, originalSelector);
    Method swizzledMethod = class_getClassMethod(swizzledClass, swizzledSelector);
    if(originalMethod && swizzledMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

void ct_addMethod(Class originalClass,Class swizzledClass, SEL swizzledSelector)
{
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, swizzledSelector);
    class_addMethod(originalClass,swizzledSelector,method_getImplementation(swizzledMethod),method_getTypeEncoding(swizzledMethod));
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class card_class = objc_getClass("HookClass");
        if (card_class) {
            ct_hookMethod(card_class, @selector(originSelector:), [self class], @selector(hookSelector:));
        }
    });
}

- (void)hookSelector:(id)arg
{
   [self hookeSelector:arg];
}

@end

```



---
layout: post
title: PlistBuddy
date: 2021-04-23
tags: iOS
---

# PlistBuddy

`PlistBuddy` 是 `Mac` 系统中一个用于命令行下读写 `plist` 文件的工具。可以用来读取或修改 `plist` 文件的内容。

- `PlistBuddy` 工具路径

```
/usr/libexec/PlistBuddy
```

- 可以在 `/usr/local/bin/` 目录下建立软连接，就可以直接使用 PlistBuddy 命令了

```
# 不能直接使用 PlistBuddy 命令
ln -s /usr/libexec/PlistBuddy /usr/local/bin/PlistBuddy
```
- 查看帮助

```
/usr/libexec/PlistBuddy --help
```

# 操作 `plist` 文件

- 打印 `info.plist` 文件


```
/usr/libexec/PlistBuddy -c "Print" info.plist
```
- 打印字段相应的值

```
# 打印 info.plist 中字段 name 值
/usr/libexec/PlistBuddy -c 'Print :name' info.plist

# 脚本中获取 plist 文件中字段 name 值，并赋值给变量
name=$($PlistBuddy -c "print :name" info.plist)

# 打印数组字段 testArr 第 0 项
/usr/libexec/PlistBuddy -c 'Print :testArr:0' info.plist
```

- 添加字段

| 字段类型 |
| --- |
| string | |
| array | |
| dict | |
| bool | |
| real | |
| integer | |
| date | |
| data | |


```
# string 类型：给 test.plist 文件添加字段 Version 值为 1.0.0
/usr/libexec/PlistBuddy -c 'Add :Version string 1.0.0' test.plist
```

```
# Array 类型：给 test.plist 文件添加数组字段 AppArr

# 1. 添加 key 值
/usr/libexec/PlistBuddy -c 'Add :AppArr array' test.plist

# 注意：key之间用 : 隔开，且不能有空格：

# 2. 添加 value 值 app1 、app2
/usr/libexec/PlistBuddy -c 'Add :AppArr: string app1' test.plist
/usr/libexec/PlistBuddy -c 'Add :AppArr: string app2' test.plist
```

```
# Dictionary 类型： 给 test.plist 文件添加数组字段 AppDic

# 1. 添加 key 值
/usr/libexec/PlistBuddy -c 'Add :AppDic dict' test.plist

# 2. 添加 value 值 name 、age
/usr/libexec/PlistBuddy -c 'Add :AppDic:name string Tom' test.plist
/usr/libexec/PlistBuddy -c 'Add :AppDic:age string 100' test.plist
```

- 删除字段

```
# 删除 test.plist 中的字段 Version
/usr/libexec/PlistBuddy -c 'Delete :Version' test.plist
```

- 修改字段值
 
```
# 修改 string 类型
/usr/libexec/PlistBuddy -c 'Set :version "1.1.1"' test.plist

# 修改 array 类型. 修改 AppArr 字段中数组的第0个值.
/usr/libexec/PlistBuddy -c 'Set :AppArr:0 "this is app1"' test.plist

# 修改 dict 类型. 修改 AppDic 字段中 name 的值
/usr/libexec/PlistBuddy -c 'Set :AppDic:name "Jim"' test.plist
```

- 合并两个 plist

```
# 把 A.plist 合并到 B.plist. 有相同字段，会发生覆盖。
/usr/libexec/PlistBuddy -c 'Merge A.plist' B.plist
```




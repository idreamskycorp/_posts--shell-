---
layout: post
title: shell编程：find命令
date: 2019-12-09
tags: Shell
---

----

在linux的日常管理中，find的使用频率很高，熟练掌握对提高工作效率很有帮助。

find的语法比较简单，常用参数的就那么几个，比如-name、-type、-ctime等。初学的同学直接看第二部分的例子，如需进一步了解参数说明，可以参考find的帮助文档。

find语法如下：

find(选项)(参数)

常用例子
----

### 根据文件名查找

列出当前目录以及子目录下的所有文件

```
find .
```
找到当前目录下名字为11.png的文件

```
find . -name "11.png"
```
找到当前目录下所有的jpg文件

```
find . -name "*.jpg"
```
找到当前目录下的jpg文件和png文件

```
find . -name "*.jpg" -o -name "*.png"
```
找出当前目录下不是以png结尾的文件

```
find . ! -name "*.png"
```

### 根据正则表达式查找

备注：正则表示式比原先想的要复杂，支持好几种类型。可以参考[这里](http://www.gnu.org/software/findutils/manual/html_mono/find.html#emacs-regular-expression-syntax)

找到当前目录下，文件名都是数字的png文件。

```
find . -regex "\./*[0-9]+\.png"
```

### 根据路径查找

找出当前目录下，路径中包含wysiwyg的文件/路径。

```
find . -path "*wysiwyg*"
```

### 根据文件类型查找

通过-type进行文件类型的过滤。

  - f 普通文件
  - l 符号连接
  - d 目录
  - c 字符设备
  - b 块设备
  - s 套接字
  - p Fifo

举例，查找当前目录下，路径中包含wysiwyg的文件

```
find . -type f -path "*wysiwyg*"
```

### 限制搜索深度

找出当前目录下所有的png，不包括子目录。

```
find . -maxdepth 1 -name "*.png"
```
相对应的，也是mindepth选项。

```
find . -mindepth 2 -maxdepth 2 -name "*.png"
```

### 根据文件大小

通过-size来过滤文件尺寸。支持的文件大小单元如下

  - b —— 块（512字节）
  - c —— 字节
  - w —— 字（2字节）
  - k —— 千字节
  - M —— 兆字节
  - G —— 吉字节

举例来说，找出当前目录下文件大小超过100M的文件

```
find . -type f -size +100M
```

### 根据访问/修改/变化时间

支持下面的时间类型。

  - 访问时间（-atime/天，-amin/分钟）：用户最近一次访问时间。
  - 修改时间（-mtime/天，-mmin/分钟）：文件最后一次修改时间。
  - 变化时间（-ctime/天，-cmin/分钟）：文件数据元（例如权限等）最后一次修改时间。

举例，找出1天内被修改过的文件

```
find . -type f -mtime -1
```
找出最近1周内被访问过的文件

```
find . -type f -atime -7
```
将日志目录里超过一个礼拜的日志文件，移动到/tmp/old\_logs里。

```
find . -type f -mtime +7 -name "*.log" -exec mv {} /tmp/old_logs \;
```
注意：{} 用于与-exec选项结合使用来匹配所有文件，然后会被替换为相应的文件名。

另外，\;用来表示命令结束，如果没有加，则会有如下提示

```
find: -exec: no terminating ";" or "+"
```

### 根据权限

通过-perm来实现。举例，找出当前目录下权限为777的文件

```
find . -type f -perm 777
```
找出当前目录下权限不是644的php文件

```
find . -type f -name "*.php" ! -perm 644
```

### 根据文件拥有者

找出文件拥有者为root的文件

```
find . -type f -user root
```
找出文件所在群组为root的文件

```
find . -type f -group root
```

### 找到文件后执行命令

通过-ok、和-exec来实现。区别在于，-ok在执行命令前，会进行二次确认，-exec不会。

看下实际例子。删除当前目录下所有的js文件。用-ok的效果如下，删除前有二次确认

```
➜ find find . -type f -name "*.js" -ok rm {} \; "rm ./1.js"?
```
试下-exec。直接就删除了

```
find . -type f -name "*.js" -exec rm {} \;
```

### 找出空文件

例子如下

```
touch {1..9}.txt echo "hello" > 1.txt find . -empty
```


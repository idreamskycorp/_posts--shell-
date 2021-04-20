---
layout: post
title: 09_SHELL编程之xarg使用
date: 2018-05-03
tags: Shell
---


*xargs 是给命令传递参数的一个过滤器，可以将管道或标准输入的数据转换成参数，默认的命令是 echo，这意味着通过管道传递给 xargs 的输入将会包含换行，不过通过 xargs 的处理，换行将被空格取代。*

# 1. 如何使用xargs命令
语法：


```
xargs [OPTIONS] [COMMAND [initial-arguments]]
```


举一个例子：我们用管道符传输到xargs，并为每个参数运行touch命令，-t表示在执行之前先打印，创建三个文件：

```
[root@localhost ~]# echo "file1 file2 file3"|xargs -t touch
touch file1 file2 file3
```

# 2. *如何限制参数的数量*
默认情况下，传递给命令的参数数量由系统限制决定。-n选项指定要传递给命令的参数个数。xargs根据需要多次运行指定的命令，直到所有参数都用完为止。

下面例子指定每次传递一个参数：

```
[root@localhost ~]# echo "file1 file2 file3"|xargs -n1 -t touch
touch file1 
touch file2 
touch file3
```

# 3. 如何运行多个命令
要使用xargs运行多个命令，请使用-i或者-I选项。在-i或者-I后面自定义一个传递参数符号，所有匹配的项都会替换为传递给xargs的参数。

下面例子时xargs运行两条命令，先touch创建文件，然后ls列出来：


```
[root@localhost ~]# echo "file1 file2 file3"|xargs -t -I % sh -c 'touch %;ls -l %'
sh -c touch file1 file2 file3;ls -l file1 file2 file3 
-rw-r--r--. 1 root root 0 Jan 30 00:18 file1
-rw-r--r--. 1 root root 0 Jan 30 00:18 file2
-rw-r--r--. 1 root root 0 Jan 30 00:18 file3
```

# 4. 如何指定一个分隔符
使用-d或者--delimiter选项设置自定义分隔符，可以是单个字符，也可以是以\ 开头的转义字符。

下面例子使用#做分隔符，echo命令使用了-n选项，意思是不输出新行：


```
[root@localhost ~]# echo -n file1#file2#file3#file4|xargs -d \# -t touch
touch file1 file2 file3 file4
```

# 5. 如何从文件中读取条目
xargs命令还可以从文件读取条目，而不是从标准输入读取条目。使用-a选项，后跟文件名。
创建一个ip.txt的文件，一会使用xargs命令ping里面的每一个地址：


```
[root@localhost ~]# cat ip.txt 
114.114.114.114
www.linuxprobe.com
202.102.128.68
```

使用-L 1选项，该选项表示xargs一次读取一行。如果省略此选项，xargs将把所有ip传递给一个ping命令。


```
[root@localhost ~]# xargs -a ip.txt -t -L 1 ping -c 1
ping -c 1 114.114.114.114 
PING 114.114.114.114 (114.114.114.114) 56(84) bytes of data.
64 bytes from 114.114.114.114: icmp_seq=1 ttl=93 time=11.0 ms

--- 114.114.114.114 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 11.026/11.026/11.026/0.000 ms
ping -c 1 www.linuxprobe.com 
PING www.linuxprobe.com.w.kunlunno.com (221.15.65.202) 56(84) bytes of data.
64 bytes from hn.kd.jz.adsl (221.15.65.202): icmp_seq=1 ttl=48 time=20.9 ms

--- www.linuxprobe.com.w.kunlunno.com ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 20.934/20.934/20.934/0.000 ms
ping -c 1 202.102.128.68 
PING 202.102.128.68 (202.102.128.68) 56(84) bytes of data.
64 bytes from 202.102.128.68: icmp_seq=1 ttl=83 time=8.71 ms

--- 202.102.128.68 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 8.710/8.710/8.710/0.000 ms
```

# 6. xargs与find一起使用
xargs通常与find命令结合使用。您可以使用find搜索特定文件，然后使用xargs对这些文件执行操作。

若要避免包含换行符或其他特殊字符的文件名出现问题，请始终使用find的-print0选项，这样可以使find打印完整的文件名，配合xargs命令使用-0或者--null选项可以正确的解释。

下面例子中，查找log文件夹下面的类型为file的所有文件，打包压缩起来：


```
[root@localhost ~]# find log/ -type f -print0|xargs --null tar -zcvf logs.tar.gz
log/anaconda/anaconda.log
log/anaconda/syslog
log/anaconda/program.log
log/anaconda/packaging.log
log/anaconda/storage.log
log/anaconda/ifcfg.log
log/anaconda/ks-script-TOLvJc.log
log/anaconda/ks-script-VRY9yQ.log
log/anaconda/ks-script-pjDijm.log
log/anaconda/journal.log
log/audit/audit.log
log/boot.log
log/boot.log-20200126
log/btmp
log/btmp-20200126
…
[root@localhost ~]# ll
total 604
-rw-------. 1 root root   1285 Dec 21 17:19 anaconda-ks.cfg
drwxr-xr-x. 8 root root   4096 Jan 29 23:02 log
-rw-r--r--. 1 root root 607566 Jan 30 00:58 logs.tar.gz
```

# 总结
之所以能用到这个命令，关键是由于很多命令不支持管道符来传递参数，xargs可以解决这个问题，而且使用起来很方便，跟能强大。

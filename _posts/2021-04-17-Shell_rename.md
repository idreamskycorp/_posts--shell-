---
layout: post
title: Shell批量重命名
date: 2021-04-17
tags: Shell
---

## 第一种方法
```
CURRENT_DIR=`pwd`

for dir in *
do
    if [ -d $dir ];then
        for file in $dir/*
        do
            NEW_FILE=${file/XXXXXXX/}
            if [ "$NEW_FILE" != "$file" ] ;then
                mv "${CURRENT_DIR}/$file" "${CURRENT_DIR}/${NEW_FILE}"
                if [ $? -eq 0 ] ;then
                    echo "${CURRENT_DIR}/${NEW_FILE}"
                    echo "替换成功"
                fi
            fi
            #echo $CURRENT_DIR ----- $dir --- $file
            
        done
    fi
    
done
```
## 其他实现
```
0、用类似 GPRename 这样的图形软件进行批量重命名

#1、删除所有的 .bak 后缀：
rename 's/\.bak$//' *.bak

#2、把 .jpe 文件后缀修改为 .jpg：
rename 's/\.jpe$/\.jpg/' *.jpe

#3、把所有文件的文件名改为小写：
rename 'y/A-Z/a-z/' *

#4、将 abcd.jpg 重命名为 abcd_efg.jpg：
for var in *.jpg; do mv "$var" "${var%.jpg}_efg.jpg"; done

#5、将 abcd_efg.jpg 重命名为 abcd_lmn.jpg：
for var in *.jpg; do mv "$var" "${var%_efg.jpg}_lmn.jpg"; done

#6、把文件名中所有小写字母改为大写字母：
for var in `ls`; do mv -f "$var" `echo "$var" |tr a-z A-Z`; done

#7、把格式 *_?.jpg 的文件改为 *_0?.jpg：
for var in `ls *_?.jpg`; do mv "$var" `echo "$var" |awk -F '_' '{print $1 "_0" $2}'`; done

#8、把文件名的前三个字母变为 vzomik：
for var in `ls`; do mv -f "$var" `echo "$var" |sed 's/^.../vzomik/'`; done

#9、把文件名的后四个字母变为 vzomik：
for var in `ls`; do mv -f "$var" `echo "$var" |sed 's/....$/vzomik/'`; done

#10. 把.txt变成.txt_bak 的后缀
ls *.txt|xargs -n1 -i{} mv {} {}_bak
# xargs -n1 –i{} 类似for循环，-n1意思是一个一个对象的去处理，-i{} 把前面的对象使用{}取代，mv {} {}_bak 相当于 mv 1.txt 1.txt_bak

find ./*.txt -exec mv {} {}_bak \;  
#这个命令中也是把{}作为前面find出来的文件的替代符，后面的”\”为”;”的脱意符，不然shell会把分号作为该行命令的结尾.


==================================================================

既然要批量替换文件名，那么肯定得用一个for循环依次遍历指定目录下的每个文件。对于每个文件，假如该文件的名称为name.oldext，那么我们必须原始文件名中挖出name，再将它与新的文件扩展名newext拼接形成新的文件名name.newext。依照这样的思路，就诞生了下面的脚本：
#!/bin/bash
oldext="JPG"
newext="jpg"
dir=$(eval pwd)

for file in $(ls $dir | grep .$oldext)
        do
        name=$(ls $file | cut -d. -f1)
        mv $file ${name}.$newext
        done
echo "change JPG=====>jpg done!"

        下面对针对这个程序作简单说明：
1.变量oldext和newext分别指定旧的扩展名和新的扩展名。dir指定文件所在目录；
2.“ls $dir | grep .$oldext”用来在指定目录dir中获取扩展名为旧扩展名的所有文件；
3.在循环体内先利用cut命令将文件名中“.”之前的字符串剪切出来，并赋值给name变量；接着将当前的文件名重命名为新的文件名。
        通过这个脚本，所有照片的扩展名都成功修改。为了使这个脚本更具有通用型，我们可以增加几条read命令实现脚本和用户之间的交互。改进版的脚本如下：
#!/bin/bash
read -p "old extension:" oldext
read -p "new extension:" newext
read -p "The directory:" dir
cd $dir

for file in $(ls $dir | grep .$oldext)
        do
        name=$(ls $file | cut -d. -f1)
        mv $file ${name}.$newext
        echo "$name.$oldext ====> $name.$newext"
        done

echo "all files has been modified."
        修改后的脚本可以批量修改任意扩展名。

```
```
Shell批量重命名文件名
#!/bin/sh
#替换文件名中的空格
find . -name "* *"|
while read name;do
    na=$(echo $name | tr ' ' '_')
    mv "$name" $na
done

#将文件名替换成1、2、3、4、5、6等文件名，后缀名保持不变（例如test.log -->1.log）
for file in `find . -type f -name "*"`;do 
dirname=`dirname $file`

 i=`expr $i + 1`;
#获取文件后缀名
 P="${file##*.}"
echo $file $dirname/$i.$P;

mv $file $dirname/$i.$P;
done

```



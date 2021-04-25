#!/bin/bash


dirname=`dirname $0`
files=`ls -t ./_posts`
files=($files)
if [[ ${#files[@]} > 1 ]]; then
    lastModifyFile=${files[0]}
fi
if [ ! -z $lastModifyFile ]; then
     lastModifyFile="${dirname}/_posts/${lastModifyFile}"
     echo $lastModifyFile
fi
if [ -e $lastModifyFile ]; then
    title=`awk '/^title:/{gsub(/[[:blank:]]*/,"",$0);print $0}' ""$lastModifyFile""`
    title=${title#*:}
fi

if [ ! -z $title ]; then
     git add -A
     git commit -m "更新【${title}】"
     git push
     echo "提交【${title}】成功"
else
     echo "提交失败"
fi


# echo $title
#/Users/syswin/Desktop/MySite/_posts/2018-04-15-01_SHELL.md

# case "${input}" in
#     [yY][eE][sS]|[yY])
#         echo "-----------"
#     ;;
# esac



# git status
 
# read -r -p "是否继续提交? [Y/n] " input
 
# case $input in
#     [yY][eE][sS]|[yY])
#         echo "继续提交"
#         git add -A
#         git commit -m $1
#         git push origin $2
#                     exit 1
#         ;;

#     [nN][oO]|[nN])
#         echo "中断提交"
#         exit 1
#             ;;

#     *)
#     echo "输入错误，请重新输入"
#     ;;
# esac
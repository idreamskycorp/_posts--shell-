---
layout: post
title: 利用shell读取README.MD配置修改配置环境
date: 2021-06-04
tags: shell
---

**READM.ME内容**
```
|企业证书|key|详情|
---|---|---
企业证书 | `PRODUCT_BUNDLE_IDENTIFIER` | `com.helloworld.enterprise.app`
 | `DEVELOPMENT_TEAM` | `TLWGLP697Z5D`
 | `PROVISIONING_PROFILE_SPECIFIER` | `HaiDianTong_Distribution`
 App Store证书 | `PRODUCT_BUNDLE_IDENTIFIER` | `com.helloworld.app`
  | `DEVELOPMENT_TEAM` | `9D4SRNFSVF43`
  | `PROVISIONING_PROFILE_SPECIFIER` | `app_Distribution`
 Debug证书 | `PRODUCT_BUNDLE_IDENTIFIER` | `com.helloworld.beijingtong`
 | `DEVELOPMENT_TEAM` | `XYD7AF2EXNZZ`
 | `PROVISIONING_PROFILE_SPECIFIER` | `BeiJingRenShe_Development`


|数据环境|key|详情|
---|---|---
线上环境 | `toon_router_domain` | `http://routerhd.hebeizhichuang.com/user/router/basicRouter`
 |`cdtp_dns_router`| `http://www.cdtpdns.com/`
 |`sensorsAnalyticsServerUrl`| `https://da.helloworld.com/sa?project=production`
 |`sensorsAnalyticsConfigUrl`| `https://da.helloworld.com/config/?project=production`
t600环境| `toon_router_domain` | `http://routert600.helloworld.com/user/router/basicRouter`
 |`cdtp_dns_router` | `http://cdtpdnstmail.helloworld.com`
 |`sensorsAnalyticsServerUrl` | `https://da.helloworld.com/sa?project=default`
 |`sensorsAnalyticsConfigUrl` | `https://da.helloworld.com/config/?project=default`
```

## 切换测试、线上环境
```
#!/bin/bash

function Set_Info_Plist(){
   /usr/libexec/PlistBuddy -c "Set :$1 $2" $info_plist
}

ENV_TOON=`awk -F: 'BEGIN{};/toon_router_domain/{ gsub(/[[:blank:]]*/,"",$0);gsub(/\`/,"",$0);print $0 }' ../README.MD|cut -d\| -f3`
ENV_CDTP=`awk -F: 'BEGIN{};/cdtp_dns_router/{ gsub(/[[:blank:]]*/,"",$0); gsub(/\`/,"",$0);print $0 }' ../README.MD|cut -d\| -f3`
ENV_SENSOR_SERVER=`awk -F: 'BEGIN{};/sensorsAnalyticsServerUrl/{ gsub(/[[:blank:]]*/,"",$0); gsub(/\`/,"",$0);print $0 }' ../README.MD|cut -d\| -f3`
ENV_SENSOR_CONFIG=`awk -F: 'BEGIN{};/sensorsAnalyticsConfigUrl/{ gsub(/[[:blank:]]*/,"",$0); gsub(/\`/,"",$0);print $0 }' ../README.MD|cut -d\| -f3`

ENV_TOON=($ENV_TOON)
ENV_CDTP=($ENV_CDTP)
ENV_SENSOR_SERVER=($ENV_SENSOR_SERVER)
ENV_SENSOR_CONFIG=($ENV_SENSOR_CONFIG)

if [ ${#ENV_TOON[*]} -eq 2 -a ${#ENV_CDTP[*]} -eq 2 ]; then
    ENV_TOON_RELEASE=${ENV_TOON[0]}
    ENV_TOON_DEVELOPMENT=${ENV_TOON[1]}

    ENV_CDTP_RELEASE=${ENV_CDTP[0]}
    ENV_CDTP_DEVELOPMENT=${ENV_CDTP[1]}
else 
    echo 获取失败
    exit -1
fi

if [ ${#ENV_SENSOR_SERVER[*]} -eq 2 -a ${#ENV_SENSOR_CONFIG[*]} -eq 2 ]; then
    ENV_SENSOR_SERVER_RELEASE=${ENV_SENSOR_SERVER[0]}
    ENV_SENSOR_SERVER_DEVELOPMENT=${ENV_SENSOR_SERVER[1]}

    ENV_SENSOR_CONFIG_RELEASE=${ENV_SENSOR_CONFIG[0]}
    ENV_SENSOR_CONFIG_DEVELOPMENT=${ENV_SENSOR_CONFIG[1]}
else 
    echo 获取失败
    exit -1
fi
echo "--------toon_router_domain develop------------"
echo $ENV_TOON_DEVELOPMENT
# echo $ENV_TOON_RELEASE1
echo "--------toon_router_domain release------------"
echo $ENV_TOON_RELEASE


echo "--------cdtp_dns_router develop------------"
echo $ENV_CDTP_DEVELOPMENT
# echo $ENV_CDTP_RELEASE1
echo "--------cdtp_dns_router release------------"
echo $ENV_CDTP_RELEASE

echo "--------sensorsAnalyticsServerUrl develop------------"
echo $ENV_SENSOR_SERVER_DEVELOPMENT
echo "--------sensorsAnalyticsServerUrl release------------"
echo $ENV_SENSOR_SERVER_RELEASE

echo "--------sensorsAnalyticsConfigUrl develop------------"
echo $ENV_SENSOR_CONFIG_DEVELOPMENT
echo "--------sensorsAnalyticsConfigUrl release------------"
echo $ENV_SENSOR_CONFIG_RELEASE


info_plist=./TLauncher/Info.plist

if [ ! -f $info_plist ]; then
    echo "找不到plist文件"
    exit -1
fi


CURRENT_TOON_ENV=$(/usr/libexec/PlistBuddy -c 'Print toon_router_domain' $info_plist)

echo "------两个环境比较---------"
echo $CURRENT_TOON_ENV
echo $ENV_TOON_DEVELOPMENT
if [ $ENV_TOON_DEVELOPMENT == $CURRENT_TOON_ENV ]; then
    Set_Info_Plist "toon_router_domain" $ENV_TOON_RELEASE
    Set_Info_Plist "cdtp_dns_router" $ENV_CDTP_RELEASE
    Set_Info_Plist "sensorsAnalyticsServerUrl" $ENV_SENSOR_SERVER_RELEASE
    Set_Info_Plist "sensorsAnalyticsConfigUrl" $ENV_SENSOR_CONFIG_RELEASE
    echo 由之前测试环境修改为线上环境
 else 
    Set_Info_Plist "toon_router_domain" $ENV_TOON_DEVELOPMENT
    Set_Info_Plist "cdtp_dns_router" $ENV_CDTP_DEVELOPMENT
    Set_Info_Plist "sensorsAnalyticsServerUrl" $ENV_SENSOR_SERVER_DEVELOPMENT
    Set_Info_Plist "sensorsAnalyticsConfigUrl" $ENV_SENSOR_CONFIG_DEVELOPMENT
    echo 由之前线上环境修改为测试环境
fi

```
## 证书切换
```
set -e
set -u
set -o pipefail

README_PATH="$SRCROOT/../README.MD"
PBXPROJ_PATH="$PROJECT_FILE_PATH/project.pbxproj"
PRODUCT_BUNDLE_IDENTIFIER=`awk 'BEGIN{};/PRODUCT_BUNDLE_IDENTIFIER/{ gsub(/[[:blank:]]*/,"",$0);gsub(/\`/,"",$0);print $0 }' $README_PATH|cut -d\| -f3`
DEVELOPMENT_TEAM=`awk 'BEGIN{};/DEVELOPMENT_TEAM/{ gsub(/[[:blank:]]*/,"",$0);gsub(/\`/,"",$0);print $0 }' $README_PATH|cut -d\| -f3`
PROVISIONING_PROFILE_SPECIFIER=`awk 'BEGIN{};/PROVISIONING_PROFILE_SPECIFIER/{ gsub(/[[:blank:]]*/,"",$0);gsub(/\`/,"",$0);print $0 }' $README_PATH|cut -d\| -f3`

CONFIG_COUNT=3


echo $PRODUCT_BUNDLE_IDENTIFIER
echo $DEVELOPMENT_TEAM
echo $PROVISIONING_PROFILE_SPECIFIER

PRODUCT_BUNDLE_IDENTIFIER=($PRODUCT_BUNDLE_IDENTIFIER)
DEVELOPMENT_TEAM=($DEVELOPMENT_TEAM)
PROVISIONING_PROFILE_SPECIFIER=($PROVISIONING_PROFILE_SPECIFIER)
if [ ${#PRODUCT_BUNDLE_IDENTIFIER[*]} -eq $CONFIG_COUNT -a ${#DEVELOPMENT_TEAM[*]} -eq $CONFIG_COUNT -a ${#PROVISIONING_PROFILE_SPECIFIER[*]} -eq $CONFIG_COUNT ]; then
    ############################ 内部市场 Bundle ID #############################
    PRODUCT_BUNDLE_IDENTIFIER_ENTERPRISE=${PRODUCT_BUNDLE_IDENTIFIER[0]}
    ############################ App Store Bundle ID #############################
    PRODUCT_BUNDLE_IDENTIFIER_APPSTORE=${PRODUCT_BUNDLE_IDENTIFIER[1]}

    ############################ 内部市场证书#############################
    PROVISIONING_PROFILE_SPECIFIER_ENTERPRISE_Distribution=${PROVISIONING_PROFILE_SPECIFIER[0]}
    ############################ App Store 证书#############################
    PROVISIONING_PROFILE_SPECIFIER_APPSTORE_Distribution=${PROVISIONING_PROFILE_SPECIFIER[1]}

    ############################ 内部市场 TEAM #############################
    DEVELOPMENT_TEAM_ENTERPRISE=${DEVELOPMENT_TEAM[0]}
    ############################ App Store TEAM #############################
    DEVELOPMENT_TEAM_APPSTORE=${DEVELOPMENT_TEAM[1]}

    echo $PRODUCT_BUNDLE_IDENTIFIER_ENTERPRISE $PROVISIONING_PROFILE_SPECIFIER_ENTERPRISE_Distribution $DEVELOPMENT_TEAM_ENTERPRISE
    echo $PRODUCT_BUNDLE_IDENTIFIER_APPSTORE $PROVISIONING_PROFILE_SPECIFIER_APPSTORE_Distribution $DEVELOPMENT_TEAM_APPSTORE

    PRODUCT_BUNDLE_IDENTIFIER_PROJ=`awk 'BEGIN{};/PRODUCT_BUNDLE_IDENTIFIER/{ gsub(/[[:blank:]]*/,"",$0);print $0 }' $PBXPROJ_PATH`
    echo ----------------
    echo $PBXPROJ_PATH
    echo $PRODUCT_BUNDLE_IDENTIFIER_PROJ
    echo $PROJECT_FILE_PATH
    echo $PBXPROJ_PATH                       
    echo ----------------
    if [[ $PRODUCT_BUNDLE_IDENTIFIER_PROJ =~ $PRODUCT_BUNDLE_IDENTIFIER_ENTERPRISE ]]; then
        echo '由企业证书改为App Store证书'
        sed -i '' -e 's/PROVISIONING_PROFILE_SPECIFIER\ =\ .*/PROVISIONING_PROFILE_SPECIFIER\ =\ '$PROVISIONING_PROFILE_SPECIFIER_APPSTORE_Distribution'\;/' $PBXPROJ_PATH
        sed -i '' -e 's/PRODUCT_BUNDLE_IDENTIFIER\ =\ .*/PRODUCT_BUNDLE_IDENTIFIER\ =\ '$PRODUCT_BUNDLE_IDENTIFIER_APPSTORE'\;/' $PBXPROJ_PATH
        sed -i '' -e 's/DEVELOPMENT_TEAM\ =\ .*/DEVELOPMENT_TEAM\ =\ '$DEVELOPMENT_TEAM_APPSTORE'\;/' $PBXPROJ_PATH
    elif [[ $PRODUCT_BUNDLE_IDENTIFIER_PROJ =~ $PRODUCT_BUNDLE_IDENTIFIER_APPSTORE ]]; then
        echo '由App Store证书改为企业证书'
        sed -i '' -e 's/PROVISIONING_PROFILE_SPECIFIER\ =\ .*/PROVISIONING_PROFILE_SPECIFIER\ =\ '$PROVISIONING_PROFILE_SPECIFIER_ENTERPRISE_Distribution'\;/' $PBXPROJ_PATH
        sed -i '' -e 's/PRODUCT_BUNDLE_IDENTIFIER\ =\ .*/PRODUCT_BUNDLE_IDENTIFIER\ =\ '$PRODUCT_BUNDLE_IDENTIFIER_ENTERPRISE'\;/' $PBXPROJ_PATH
        sed -i '' -e 's/DEVELOPMENT_TEAM\ =\ .*/DEVELOPMENT_TEAM\ =\ '$DEVELOPMENT_TEAM_ENTERPRISE'\;/' $PBXPROJ_PATH
    fi

else 
    echo '修改失败'
    exit -1
fi

```

## 设置debug证书

```
# Type a script or drag a script file from your workspace to insert its path.
set -e
set -u
set -o pipefail

README_PATH="$SRCROOT/../README.MD"
PBXPROJ_PATH="$PROJECT_FILE_PATH/project.pbxproj"
PRODUCT_BUNDLE_IDENTIFIER=`awk 'BEGIN{};/PRODUCT_BUNDLE_IDENTIFIER/{ gsub(/[[:blank:]]*/,"",$0);gsub(/\`/,"",$0);print $0 }' $README_PATH|cut -d\| -f3`
DEVELOPMENT_TEAM=`awk 'BEGIN{};/DEVELOPMENT_TEAM/{ gsub(/[[:blank:]]*/,"",$0);gsub(/\`/,"",$0);print $0 }' $README_PATH|cut -d\| -f3`
PROVISIONING_PROFILE_SPECIFIER=`awk 'BEGIN{};/PROVISIONING_PROFILE_SPECIFIER/{ gsub(/[[:blank:]]*/,"",$0);gsub(/\`/,"",$0);print $0 }' $README_PATH|cut -d\| -f3`
CONFIG_COUNT=3
echo $PRODUCT_BUNDLE_IDENTIFIER
echo $DEVELOPMENT_TEAM
echo $PROVISIONING_PROFILE_SPECIFIER

PRODUCT_BUNDLE_IDENTIFIER=($PRODUCT_BUNDLE_IDENTIFIER)
DEVELOPMENT_TEAM=($DEVELOPMENT_TEAM)
PROVISIONING_PROFILE_SPECIFIER=($PROVISIONING_PROFILE_SPECIFIER)
if [ ${#PRODUCT_BUNDLE_IDENTIFIER[*]} -eq $CONFIG_COUNT -a ${#DEVELOPMENT_TEAM[*]} -eq $CONFIG_COUNT -a ${#PROVISIONING_PROFILE_SPECIFIER[*]} -eq $CONFIG_COUNT ]; then
    ############################ DEBUG Bundle ID #############################
    PRODUCT_BUNDLE_IDENTIFIER_DEBUG=${PRODUCT_BUNDLE_IDENTIFIER[2]}
    ############################ DEBUG 证书#############################
    PROVISIONING_PROFILE_SPECIFIER_DEBUG=${PROVISIONING_PROFILE_SPECIFIER[2]}
    ############################ DEBGU TEAM #############################
    DEVELOPMENT_TEAM_DEBUG=${DEVELOPMENT_TEAM[2]}

    echo $PRODUCT_BUNDLE_IDENTIFIER_DEBUG $PROVISIONING_PROFILE_SPECIFIER_DEBUG $DEVELOPMENT_TEAM_DEBUG

    sed -i '' -e 's/PROVISIONING_PROFILE_SPECIFIER\ =\ .*/PROVISIONING_PROFILE_SPECIFIER\ =\ '$PROVISIONING_PROFILE_SPECIFIER_DEBUG'\;/' $PBXPROJ_PATH
    sed -i '' -e 's/PRODUCT_BUNDLE_IDENTIFIER\ =\ .*/PRODUCT_BUNDLE_IDENTIFIER\ =\ '$PRODUCT_BUNDLE_IDENTIFIER_DEBUG'\;/' $PBXPROJ_PATH
    sed -i '' -e 's/DEVELOPMENT_TEAM\ =\ .*/DEVELOPMENT_TEAM\ =\ '$DEVELOPMENT_TEAM_DEBUG'\;/' $PBXPROJ_PATH

else 
    echo '修改失败'
    exit -1
fi

```

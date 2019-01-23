#!/bin/bash

Cyan='\033[0;36m'
Default='\033[0;m'

version=""
repoName=""
description=""
confirmed="n"

getVersion() {
    read -p "请输入版本号: " version

    if test -z "$version"; then
        getVersion
    fi
}

getDescription() {
    read -p "请输入更新描述: " description

    if test -z "$description"; then
        getDescription
    fi
}


getInfomation() {
getVersion
getDescription

echo -e "\n${Default}================================================"
echo -e "  Version  :  ${Cyan}${version}${Default}"
echo -e "  Description :  ${Cyan}${description}${Default}"
echo -e "================================================\n"
}

echo -e "\n"
while [ "$confirmed" != "y" -a "$confirmed" != "Y" ]
do
if [ "$confirmed" == "n" -o "$confirmed" == "N" ]; then
getInfomation
fi
read -p "确定? (y/n):" confirmed
done

git add .
git commit -m $description
git tag $version
git push
git push --tags
pod trunk push --allow-warnings
say "finished"
echo "finished"

#!/bin/bash

printf "\033c"
{
    for ((i = 0 ; i <= 100 ; i+=10)); do
        sleep 0.05
        echo $i
    done
} | whiptail --gauge "Please wait while installing" 6 60 0
echo "                                         ----------------------------------------------"
echo "                                        |                  菜单主页                     |"
echo "                                         ----------------------------------------------"
echo "                                                          1.开始游戏"
echo "                                                          2.历史分数"
echo "                                                          3.退出游戏"
echo -e "\n" 
read -p "请输入你需要操作的对应数字" num1
case $num1 in
1)
    echo "waiting"
    printf "\033c"
    
    ;;
2)
    cat score | while read line
    do
    echo $line
    done 
    ;;
3)
    exit 1
    ;;
*)
    echo "warning!"
    ;;
esac
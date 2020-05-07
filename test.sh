tail=6
function GenerateSecondQueue(){
    head=0
    #先把应该有的元素塞进去
    secondQueue=(1 2 3 4 5 6 7)
    #执行洗牌算法
    local i=6
    for(( i = 6; i >= 0; --i )){
        local target=$(($RANDOM %7))
        local temp=${secondQueue[$target]}
        secondQueue[$target]=${secondQueue[$i]}
        secondQueue[$i]=$temp
    }
}
#取出一个元素后更新第一个队列
function UpdateFirstQueue(){    
    local i=0
    for(( i = 0; i < 5; ++i)) {
        firstQueue[$i]=${firstQueue[$((i+1))]}
    }
    firstQueue[5]=${secondQueue[$head]}
    ((head++))
    if((head==7)) 
    then
        GenerateSecondQueue
    fi
}

GenerateSecondQueue
    local i =0
    for((i=0;i < 6; ++i)) do
        firstQueue[$i]=${secondQueue[$i]}
    done
    head=6
while ((1==1))
do

UpdateFirstQueue

echo "firstQueue=${firstQueue[*]}"
for((i=head;i<=tail;++i)) 
    do
        printf "${secondQueue[$i]} "
    #    print "${secondQueue[$i]} "
    done
read -n 1
done
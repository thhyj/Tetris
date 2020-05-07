 #totTime 表示每一帧的总时间
 totTime=0
 #startTime 表示当前帧开始时间
 startTime=0
 #ret这个变量用来表示函数的返回值
ret=0 
#suc记录上一次落地是否成功消除方块
suc=0
#tet记录上一次消除消除的几行
tet=0
#bgmPid表示播放bgm的线程的pid
bgmPid=0
#每一个下落的方块只能与hold交换一次，所以用change记录是否交换过
change=0
#kind是当前方块的种类
kind=0
#方块朝向 顺时针旋转朝向按1 2 3 4变化，逆时针按1 4 3 2变化,初始为1
direction=1
#第二个队列，head和tail左闭右闭
secondQueue=0
#score记录分数
score=0
combo=(0 0 1 1  2 2  3 3 4 4 4 5 5 5 5 6 6 6 6 7 7)
head=0
tail=6
#第一个队列
firstQueue=0
queueElement=0
 #map用来维护界面的信息
O=(1 1 0 1 1 0 0 0 0)
I=(0 0 0 0  2 2 2 2 0 0 0 0 0 0 0 0)
S=(0 3 3 3 3 0 0 0 0)
Z=(4 4 0 0 4 4 0 0 0)
L=(5 0 0 5 0 0 5 5 0)
J=(0 6 0 0 6 0 6 6 0)
T=(0 7 0 7 7 7  0 0 0)
box=(O I S Z L J T)
#now表示正在操作的方块的矩阵状态
now=$O
#记录在手里的是哪个方块，如果是0就表示手里没有方块
inHand=0
inhandx=4
inhandy=4
#pre表示正在操作的方块的矩阵在上一时刻的状态
pre=$O
prex=0
prey=0
#tpre表示正在操作的矩阵在上一次有效操作时的状态
tpre=$O
tprex=0
tprey=0
#ghostx, ghosty表示落地预测的横纵坐标
ghostcrash=0
ghostx=0
ghosty=0
tpreghostx=0
tpreghosty=0
preghostx=0
preghosty=0
#nowx,nowy表示方块矩阵左上角当前的坐标,注意这里x表示的是在第x行,y表示的是第y列
nowx=0
nowy=0

tempx=0
tempy=0
#-1代表边框

#俄罗斯方块主界面的行列位置
colbegin=10
colend=20
rowbegin=3
rowend=23
#碰撞与否(
crash=0
#下一个方块种类
nextBLock=0
#将二维坐标转换为一维编号，x为行号，y为列号
#这是针对n*n的
function Trans() {
    local x=$1
    local y=$2
    local len=$3
    ret=$(((x*len)+(y)))
}
function InvTrans() {
    local id=$1
    local len=$2
    tempx=$(( (id - 1) / 4 ))
    tempy=$(( (id - tempx * 4) ))
}
#判断移动后是否会发生碰撞
function Check() {
    DelGhost $ghostx $ghosty
    crash=0
    local len=${#now[*]}
    if ((len==16))
    then
        len=4
    fi
    if ((len==9))
    then
        len=3
    fi
    for((i = 0; i < len; ++i)) do
            for(( j = 0; j  < len; ++j )) do
                Trans $i $j $len
                local temp1=$ret
                Decode $((i+nowx)) $((j+nowy))
                local temp2=$ret
           #     echo "temp1=${temp1}, temp2=$temp2"

                if ((now[temp1]!=0 && map[temp2]!=0))#如果成立就说明发生了碰撞
                then
              #      echo "fuck"
                    crash=1
                    return
                fi
            done
    done
}
#生成第二个队列
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
#把Hold界面的方块画进去
function AddQueueElement() {
    #echo "233"
    local i=0
    local j=0
    local x=$1
    local y=$2
    local len=${#queueElement[*]}
    #echo "len=$len"
    if ((len<9))
    then
   # echo "244"
    return;
    fi
    #echo "x=${x}, y=${y}"

    if((len==16))
    then
        len=4
    fi
    if((len==9))
    then
        len=3
    fi
    for((i = x ; i < x + len ; ++i)) do
        for((j = y; j < y + len; ++j)) do
            Trans $((i - x)) $((j - y)) $len
    #        echo "ret =  $ret"
            local temp=${queueElement[$ret]}
     #       echo "temp = $temp"
            Decode $i $j
      #      echo "i = $i, j = $j, ret = $ret"
            if((map[ret]==0))
            then
                map[$ret]=$temp
                tj=$((j*3+1))
                ti=$((i+1))
                echo -ne "\033[${ti};${tj}H"
                case "${map[$ret]}" in
                "0")
                   # echo -ne "   ";;
                   echo -ne "\033[3C";;
                "-1")
                    echo -ne "\e[1;33;44m   \e[0m";;
                "1")
                    echo -ne "\e[1;33;42m   \e[0m";;
                "2")
                    echo -ne "\e[1;33;41m   \e[0m";;
                 "3")
                    echo -ne "\e[1;33;43m   \e[0m";;   
                "4")
                    echo -ne "\e[1;33;45m   \e[0m";;
                    "5")
                    echo -ne "\e[1;33;46m   \e[0m";;
                "6")
                    echo -ne "\e[1;33;47m   \e[0m";;
                    "7")
                    echo -ne "\e[1;33;40m   \e[0m";;
            esac
            fi
        done
    done
}
#把Hold界面的方块擦掉
function DelQueueElement() {
    #echo "puchi"
    local i=0
    local j=0
    local x=$1
    local y=$2
    local len=${#queueElement[*]}
    #echo "x=${x}, y=${y}"
    #echo "length=$len"
    if ((len<9))
    then
  # echo "cnm"
    return;
    fi
    if((len==16))
    then
        len=4
    fi
    if((len==9))
    then
        len=3
    fi
    for((i = x ; i < x + len ; ++i)) do
        for((j = y; j < y + len; ++j)) do
            Trans $((i - x)) $((j - y)) $len
            temp=${queueElement[$ret]}
            if ((temp>=1)) 
            then   
                Decode $i $j
                if ((${map[$ret]} > 0))
                then
                    map[$ret]=0
                 tj=$((j*3+1))

                ti=$((i+1))
                echo -ne "\033[${ti};${tj}H"
                case "${map[$ret]}" in
                "0")
                  echo -ne "   ";;
                #   echo -ne "\033[3C";;
                "-1")
                    echo -ne "\e[1;33;44m   \e[0m";;
                "1")
                    echo -ne "\e[1;33;42m   \e[0m";;
                "2")
                    echo -ne "\e[1;33;41m   \e[0m";;
                 "3")
                    echo -ne "\e[1;33;43m   \e[0m";;   
                "4")
                    echo -ne "\e[1;33;45m   \e[0m";;
                    "5")
                    echo -ne "\e[1;33;46m   \e[0m";;
                "6")
                    echo -ne "\e[1;33;47m   \e[0m";;
                    "7")
                    echo -ne "\e[1;33;40m   \e[0m";;
            esac
                fi
                 
            fi
        done
    done
}
function PrintFirstQueue(){
    local i=0
    local x=0
    local y=22
    for((i=0;i<6;++i)) do
        ((x=3+i*4))
   #     echo "${firstQueue[$i]}"
        case ${firstQueue[$i]} in
        "1")
        queueElement=(${O[*]});;

        "2")
        queueElement=(${I[*]});;

        "3")
       queueElement=(${S[*]});;

        "4")
        queueElement=(${Z[*]});;

        "5")
        queueElement=(${L[*]});;

        "6")
        queueElement=(${J[*]});;

        "7")
        queueElement=(${T[*]});;
        esac
        AddQueueElement $x $y
    done
}
#取出一个元素后更新第一个队列
function UpdateFirstQueue(){    
    local i=0
    for(( i = 0; i < 5; ++i)) {
        case ${firstQueue[$i]} in
        "1")
        queueElement=(${O[*]});;

        "2")
        queueElement=(${I[*]});;

        "3")
       queueElement=(${S[*]});;

        "4")
        queueElement=(${Z[*]});;

        "5")
        queueElement=(${L[*]});;

        "6")
        queueElement=(${J[*]});;

        "7")
        queueElement=(${T[*]});;
        esac
        DelQueueElement $((3+i*4)) $((22))    #echo "x=${x}, y=${y}"

        firstQueue[$i]=${firstQueue[$((i+1))]}
        
    #    read -n 1 cao
    }
    case ${firstQueue[$i]} in
        "1")
        queueElement=(${O[*]});;

        "2")
        queueElement=(${I[*]});;

        "3")
       queueElement=(${S[*]});;

        "4")
        queueElement=(${Z[*]});;

        "5")
        queueElement=(${L[*]});;

        "6")
        queueElement=(${J[*]});;

        "7")
        queueElement=(${T[*]});;
        esac
    DelQueueElement $((3+5*4)) $((22))
    firstQueue[5]=${secondQueue[$head]}
   # read -n 1 cao
    ((head++))
    if((head==7)) 
    then
        GenerateSecondQueue
    fi
    PrintFirstQueue
}
#将当前方块逆时针旋转90°
function Rotate() {
#    echo "Rotate"
    Del $nowx $nowy
    pre=(${now[*]})
    local len=${#now[*]}
  #  echo "len=$len"
    if ((len == 16)) 
    then
        len=4
       # echo "233"
        for((i = 0; i < 4; ++i)) do
            for(( j = 0; j  < 4; ++j )) do
                Trans $((3-i)) $j $len
                local temp1=$ret
                Trans $j $i $len
                local temp2=$ret
                now[$temp1]=${pre[$temp2]}
            done
        done
    fi
    if ((len == 9)) 
    then
        len=3
        for((i = 0; i < 3; ++i)) do
            for(( j = 0; j  < 3; ++j )) do
                Trans $((2-i)) $j $len
                local temp1=$ret 
                Trans $j $i $len
                local temp2=$ret
                now[$temp1]=${pre[$temp2]}
            done
        done
    fi
  #  Add $nowx $nowy
    Check
   # Del $nowx $nowy
    if ((crash==1)) 
    then
    #    echo "crash"
        now=(${pre[*]})         #发生碰撞，此次旋转无效
        pre=(${tpre[*]})
        Del $tprex $tprey
    Add $nowx $nowy
    tprex=$nowx
    tprey=$nowy
    play -q skin/sfx/default/sfx_rotatefail.wav &
        return
    fi
    #维护朝向
    ((direction--))
    if ((direction==0))
    then
        direction=4
    fi
    Del $tprex $tprey
    Add $nowx $nowy
    tprex=$nowx
    tprey=$nowy
    if((crash==1)) 
    then
        play -q skin/sfx/default/sfx_rotatefail.wav &
        else 
        play -q skin/sfx/default/sfx_rotate.wav &
    fi
}
function RRotate() {
#    echo "Rotate"
    Del $nowx $nowy
    pre=(${now[*]})
    local len=${#now[*]}
  #  echo "len=$len"
    if ((len == 16)) 
    then
        len=4
       # echo "233"
        for((i = 0; i < 4; ++i)) do
            for(( j = 0; j  < 4; ++j )) do
                Trans $((3-i)) $j $len
                local temp1=$ret
                Trans $j $i $len
                local temp2=$ret
                now[$temp2]=${pre[$temp1]}
            done
        done
    fi
    if ((len == 9)) 
    then
        len=3
        for((i = 0; i < 3; ++i)) do
            for(( j = 0; j  < 3; ++j )) do
                Trans $((2-i)) $j $len
                local temp1=$ret 
                Trans $j $i $len
                local temp2=$ret
                now[$temp2]=${pre[$temp1]}
            done
        done
    fi
  #  Add $nowx $nowy
    Check
   # Del $nowx $nowy
    if ((crash==1)) 
    then
    #    echo "crash"
        now=(${pre[*]})         #发生碰撞，此次旋转无效
        pre=(${tpre[*]})
        Del $tprex $tprey
    Add $nowx $nowy
    tprex=$nowx
    tprey=$nowy
    play -q skin/sfx/default/sfx_rotatefail.wav &
        return
    fi
    #维护朝向
    ((direction++))
    if ((direction==5))
    then
        direction=1
    fi
    Del $tprex $tprey
    Add $nowx $nowy
    tprex=$nowx
    tprey=$nowy
    if((crash==1)) 
    then
        play -q skin/sfx/default/sfx_rotatefail.wav &
        else 
        play -q skin/sfx/default/sfx_rotate.wav &
    fi
}
#得到下一个方块的种类
function GetNextBlock(){
    nextBLock=${firstQueue[0]}
    UpdateFirstQueue
}
#让新的方块出现
function CreateNewBlock(){
   #DelGhost $ghostx $ghosty
    #Ghost
    direction=1
    kind=$1
    case $1 in
    "1")
    now=(${O[*]});;

    "2")
    now=(${I[*]});;

    "3")
    now=(${S[*]});;

    "4")
    now=(${Z[*]});;

    "5")
    now=(${L[*]});;

    "6")
    now=(${J[*]});;

    "7")
    now=(${T[*]});;
    esac
    nowx=3
    nowy=15
    prex=3
    prey=15
    tprex=3
    tprey=15
}
#方块落地时触发的操作
function FallToGround() {
    #play -q SEB_mino1.wav &
    change=0
    Add nowx nowy
    Clean
    GetNextBlock
    CreateNewBlock $nextBLock
    Ghost
}
function Down() {
    #echo 233
    Del $nowx $nowy
    prex=$nowx
    prey=$nowy
    ((nowx++))
    Check
    if ((crash==1)) 
    then
                 #发生碰撞,方块落地
        nowx=$prex
        nowy=$prey
        prex=$tprex
        prey=$tprey
        FallToGround
       # return
    fi
    Del $tprex $tprey
    Add $nowx $nowy
    tprex=$nowx
    tprey=$nowy
    if((crash==1)) 
    then
        play -q skin/sfx/default/sfx_movefail.wav &
        else 
        play -q skin/sfx/default/sfx_move.wav &
    fi
}
function AllDown() {
     
    while ((1)) 
    do
    Del $nowx $nowy
    prex=$nowx
    prey=$nowy
        ((nowx++))
        
        Check
        if ((crash==1)) 
        then
                    #发生碰撞,方块落地
            nowx=$prex
            nowy=$prey
            prex=$tprex
            prey=$tprey
            FallToGround
        # return
            break
        fi
    done
    Del $tprex $tprey
    Add $nowx $nowy
    tprex=$nowx
    tprey=$nowy
}
#落点预测函数
function AddGhost() {
    # echo "233"
    
    local x=$1
    local y=$2
    local len=${#now[*]}
    if ((len<9))
    then
   # echo "244"
    return;
    fi
    #echo "len=$len"
    #echo "x=${x},y=${y}"
    if((len==16))
    then
        len=4
    fi
    if((len==9))
    then
        len=3
    fi
    for((i = x ; i < x + len ; ++i)) do
        for((j = y; j < y + len; ++j)) do
            Trans $((i - x)) $((j - y)) $len
    #        echo "ret =  $ret"
            local temp=${now[$ret]}
     #       echo "temp = $temp"
            Decode $i $j
      #      echo "i = $i, j = $j, ret = $ret"
            if((map[ret]==0))
            then
                if((temp>0))
                then
                    temp=-8
                fi
                map[$ret]=$temp
                tj=$((j*3+1))
                ti=$((i+1))
                echo -ne "\033[${ti};${tj}H"
                case "${map[$ret]}" in
                "0")
                   # echo -ne "   ";;
                   echo -ne "\033[3C";;
                "-1")
                    echo -ne "\e[1;33;44m   \e[0m";;
                "1")
                    echo -ne "\e[1;33;42m   \e[0m";;
                "2")
                    echo -ne "\e[1;33;41m   \e[0m";;
                 "3")
                    echo -ne "\e[1;33;43m   \e[0m";;   
                "4")
                    echo -ne "\e[1;33;45m   \e[0m";;
                    "5")
                    echo -ne "\e[1;33;46m   \e[0m";;
                "6")
                    echo -ne "\e[1;33;47m   \e[0m";;
                    "7")
                    echo -ne "\e[1;33;40m   \e[0m";;
                    "-8")
                    echo -ne "\e[1;33;39m 0 \e[0m";;
            esac
            fi
        done
    done
}
function DelGhost() {
     local x=$1
    local y=$2
    local len=${#now[*]}
    #echo "length=$len"
    if ((len<9))
    then
   # echo "cnm"
    return;
    fi
     #   echo "x=${x}, y=${y}"

    if((len==16))
    then
        len=4
    fi
    if((len==9))
    then
        len=3
    fi
    for((i = x ; i < x + len ; ++i)) do
        for((j = y; j < y + len; ++j)) do
            Trans $((i - x)) $((j - y)) $len
            temp=${now[$ret]}
            if ((temp>=1)) 
            then   
                Decode $i $j
                if ((${map[$ret]} == -8))
                then
                    map[$ret]=0
                 tj=$((j*3+1))

                ti=$((i+1))
                echo -ne "\033[${ti};${tj}H"
                case "${map[$ret]}" in
                "0")
                  echo -ne "   ";;
                #   echo -ne "\033[3C";;
                "-1")
                    echo -ne "\e[1;33;44m   \e[0m";;
                "1")
                    echo -ne "\e[1;33;42m   \e[0m";;
                "2")
                    echo -ne "\e[1;33;41m   \e[0m";;
                 "3")
                    echo -ne "\e[1;33;43m   \e[0m";;   
                "4")
                    echo -ne "\e[1;33;45m   \e[0m";;
                    "5")
                    echo -ne "\e[1;33;46m   \e[0m";;
                "6")
                    echo -ne "\e[1;33;47m   \e[0m";;
                    "7")
                    echo -ne "\e[1;33;40m   \e[0m";;
                    "-8")
                    echo -ne "\e[1;33;39m 0 \e[0m";;
            esac
                fi
                 
            fi
        done
    done
}
function CheckGhost() {
    ghostcrash=0
    local len=${#now[*]}
    if ((len==16))
    then
        len=4
    fi
    if ((len==9))
    then
        len=3
    fi
    for((i = 0; i < len; ++i)) do
            for(( j = 0; j  < len; ++j )) do
                Trans $i $j $len
                local temp1=$ret
                Decode $((i+ghostx)) $((j+ghosty))
                local temp2=$ret
           #     echo "temp1=${temp1}, temp2=$temp2"

                if ((now[temp1]>0 && map[temp2]!=0))#如果成立就说明发生了碰撞
                then
              #      echo "fuck"
                    ghostcrash=1
                    return
                fi
            done
    done
}
function Ghost(){
  #  read -n 1 fuck
    
    DelGhost $ghostx $ghosty
    if((nowx > 16))
    then
    return
    fi
    ((ghostx=nowx+4))
    ghosty=$nowy
    while ((1)) 
    do
  #  echo "fucl"
    
    preghostx=$ghostx 
    preghosty=$ghosty
        ((ghostx++))
        
        CheckGhost
        if ((ghostcrash==1)) 
        then
                    #发生碰撞,方块落地
        #    echo "ghostx=$ghostx"
            ghostx=$preghostx
            ghosty=$preghosty
            preghostx=$tpreghostx
            preghosty=$tpreghosty
            #FallToGround
        # return
            break
        fi
    done
    DelGhost $tpreghostx $tpreghosty
    AddGhost $ghostx $ghosty
    tpreghostx=$ghostx
    tpreghosty=$ghosty
}
function Left(){
    Del $nowx $nowy
     prex=$nowx
    prey=$nowy
    ((nowy--))
    Check
    if ((crash==1)) 
    then
                 #发生碰撞,平移失败
        nowx=$prex
        nowy=$prey
        prex=$tprex
        prey=$tprey
        #return
    fi
    Del $tprex $tprey
    Add $nowx $nowy
    tprex=$nowx
    tprey=$nowy
    if((crash==1))
     then
        play -q skin/sfx/default/sfx_movefail.wav &
        else 
        play -q skin/sfx/default/sfx_move.wav &
    fi
}
function Right(){
    Del $nowx $nowy
     prex=$nowx
    prey=$nowy
    ((nowy++))
    Check
    if ((crash==1)) 
    then
                 #发生碰撞,平移失败
    #    echo "fuck"
        nowx=$prex
        nowy=$prey
        prex=$tprex
        prey=$tprey
        #return
    fi
    Del $tprex $tprey
    Add $nowx $nowy
    tprex=$nowx
    tprey=$nowy
    if((crash==1))
     then
        play -q skin/sfx/default/sfx_movefail.wav &
        else 
        play -q skin/sfx/default/sfx_move.wav &
    fi
        

}
function Move() {
    local type=$1
    case "$type" in
        "1")
            Down;;
        "2")
            Left;;
        "3")
            Right;;
        "0")
          return;;
    esac
}

#这是针对30*30的
function Decode() {
    local x=$1
    local y=$2
    ret=$(((x*30)+(y)))
}
#将map[x][y]赋值为v
function Assign() {
    local x=$1
    local y=$2
    local v=$3
    Decode $x $y
    map[$ret]=$v
}
function Draw() {
    clear
    for((i = 0; i < 30; ++i)) do 
        for(( j = 0; j < 30; ++j)) do
            Decode $i $j
  #          echo ${map[$ret]}
            case "${map[$ret]}" in
                "0")
                   # echo -ne "   ";;
                   echo -ne "\033[3C";;
                "-1")
                    echo -ne "\e[1;33;44m   \e[0m";;
                "1")
                    echo -ne "\e[1;33;42m   \e[0m";;
                "2")
                    echo -ne "\e[1;33;41m   \e[0m";;
                 "3")
                    echo -ne "\e[1;33;43m   \e[0m";;   
                "4")
                    echo -ne "\e[1;33;45m   \e[0m";;
                    "5")
                    echo -ne "\e[1;33;46m   \e[0m";;
                "6")
                    echo -ne "\e[1;33;47m   \e[0m";;
                    "7")
                    echo -ne "\e[1;33;40m   \e[0m";;
                     "-8")
                    echo -ne "\e[1;33;39m 0 \e[0m";;
            esac
        done
            echo ""
    done
    scoreUpdate
}
#把正在操作的方块画进去
function Add() {
    local x=$1
    local y=$2
    local len=${#now[*]}
    if((len==16))
    then
        len=4
    fi
    if((len==9))
    then
        len=3
    fi
    for((i = x ; i < x + len ; ++i)) do
        for((j = y; j < y + len; ++j)) do
            Trans $((i - x)) $((j - y)) $len
    #        echo "ret =  $ret"
            local temp=${now[$ret]}
     #       echo "temp = $temp"
            Decode $i $j
      #      echo "i = $i, j = $j, ret = $ret"
            if((map[ret]==0))
            then
                map[$ret]=$temp
                tj=$((j*3+1))
                ti=$((i+1))
                echo -ne "\033[${ti};${tj}H"
                case "${map[$ret]}" in
                "0")
                   # echo -ne "   ";;
                   echo -ne "\033[3C";;
                "-1")
                    echo -ne "\e[1;33;44m   \e[0m";;
                "1")
                    echo -ne "\e[1;33;42m   \e[0m";;
                "2")
                    echo -ne "\e[1;33;41m   \e[0m";;
                 "3")
                    echo -ne "\e[1;33;43m   \e[0m";;   
                "4")
                    echo -ne "\e[1;33;45m   \e[0m";;
                    "5")
                    echo -ne "\e[1;33;46m   \e[0m";;
                "6")
                    echo -ne "\e[1;33;47m   \e[0m";;
                    "7")
                    echo -ne "\e[1;33;40m   \e[0m";;
                     "8")
                    echo -ne "\e[1;33;39m 0 \e[0m";;
            esac
            fi
        done
    done
    pre=(${now[*]})
    prex=$x
    prey=$y
}
#把正在操作的方块上一个时刻在的位置擦掉
function Del() {
    local x=$1
    local y=$2
    local len=${#now[*]}
    if((len==16))
    then
        len=4
    fi
    if((len==9))
    then
        len=3
    fi
    for((i = x ; i < x + len ; ++i)) do
        for((j = y; j < y + len; ++j)) do
            Trans $((i - x)) $((j - y)) $len
            temp=${now[$ret]}
            if ((temp>=1)) 
            then   
                Decode $i $j
                if ((${map[$ret]} > 0))
                then
                    map[$ret]=0
                 tj=$((j*3+1))

                ti=$((i+1))
                echo -ne "\033[${ti};${tj}H"
                case "${map[$ret]}" in
                "0")
                  echo -ne "   ";;
                #   echo -ne "\033[3C";;
                "-1")
                    echo -ne "\e[1;33;44m   \e[0m";;
                "1")
                    echo -ne "\e[1;33;42m   \e[0m";;
                "2")
                    echo -ne "\e[1;33;41m   \e[0m";;
                 "3")
                    echo -ne "\e[1;33;43m   \e[0m";;   
                "4")
                    echo -ne "\e[1;33;45m   \e[0m";;
                    "5")
                    echo -ne "\e[1;33;46m   \e[0m";;
                "6")
                    echo -ne "\e[1;33;47m   \e[0m";;
                    "7")
                    echo -ne "\e[1;33;40m   \e[0m";;
                     "8")
                    echo -ne "\e[1;33;39m 0 \e[0m";;
            esac
                fi
                 
            fi
        done
    done
}
#把Hold界面的方块画进去
function AddInHand() {
   # echo "233"
    
    local x=$1
    local y=$2
    local len=${#inHand[*]}
    if ((len<9))
    then
   # echo "244"
    return;
    fi
    #echo "len=$len"
    if((len==16))
    then
        len=4
    fi
    if((len==9))
    then
        len=3
    fi
    for((i = x ; i < x + len ; ++i)) do
        for((j = y; j < y + len; ++j)) do
            Trans $((i - x)) $((j - y)) $len
    #        echo "ret =  $ret"
            local temp=${inHand[$ret]}
     #       echo "temp = $temp"
            Decode $i $j
      #      echo "i = $i, j = $j, ret = $ret"
            if((map[ret]==0))
            then
                map[$ret]=$temp
                tj=$((j*3+1))
                ti=$((i+1))
                echo -ne "\033[${ti};${tj}H"
                case "${map[$ret]}" in
                "0")
                   # echo -ne "   ";;
                   echo -ne "\033[3C";;
                "-1")
                    echo -ne "\e[1;33;44m   \e[0m";;
                "1")
                    echo -ne "\e[1;33;42m   \e[0m";;
                "2")
                    echo -ne "\e[1;33;41m   \e[0m";;
                 "3")
                    echo -ne "\e[1;33;43m   \e[0m";;   
                "4")
                    echo -ne "\e[1;33;45m   \e[0m";;
                    "5")
                    echo -ne "\e[1;33;46m   \e[0m";;
                "6")
                    echo -ne "\e[1;33;47m   \e[0m";;
                    "7")
                    echo -ne "\e[1;33;40m   \e[0m";;
            esac
            fi
        done
    done
}
#把Hold界面的方块擦掉
function DelInHand() {

    local x=$1
    local y=$2
    local len=${#inHand[*]}
    #echo "x=${x}, y=${y}"
    #echo "length=$len"
    if ((len<9))
    then
   # echo "cnm"
    return;
    fi
    if((len==16))
    then
        len=4
    fi
    if((len==9))
    then
        len=3
    fi
    for((i = x ; i < x + len ; ++i)) do
        for((j = y; j < y + len; ++j)) do
            Trans $((i - x)) $((j - y)) $len
            temp=${inHand[$ret]}
            if ((temp>=1)) 
            then   
                Decode $i $j
                if ((${map[$ret]} > 0))
                then
                    map[$ret]=0
                 tj=$((j*3+1))

                ti=$((i+1))
                echo -ne "\033[${ti};${tj}H"
                case "${map[$ret]}" in
                "0")
                  echo -ne "   ";;
                #   echo -ne "\033[3C";;
                "-1")
                    echo -ne "\e[1;33;44m   \e[0m";;
                "1")
                    echo -ne "\e[1;33;42m   \e[0m";;
                "2")
                    echo -ne "\e[1;33;41m   \e[0m";;
                 "3")
                    echo -ne "\e[1;33;43m   \e[0m";;   
                "4")
                    echo -ne "\e[1;33;45m   \e[0m";;
                    "5")
                    echo -ne "\e[1;33;46m   \e[0m";;
                "6")
                    echo -ne "\e[1;33;47m   \e[0m";;
                    "7")
                    echo -ne "\e[1;33;40m   \e[0m";;
            esac
                fi
                 
            fi
        done
    done
}

#分数显示函数
function scoreUpdate() {
    echo -ne "\033[23;16H"
    echo -ne "         "
    echo -ne "\033[24;16H"
    echo -ne "         "
    echo -ne "\033[23;16H"
    echo "score:$score"
    echo -ne "\033[24;16H"
    echo "combo:$suc"
    echo $score > score
}
function Init() {
    #先生成一波第二个队列，然后前6个元素丢进第一个里
    GenerateSecondQueue
    local i=0
    for((i=0;i < 6; ++i)) do
        firstQueue[$i]=${secondQueue[$i]}
    done
    head=6
    #初始化为0
    for(( i = 0 ; i <900;++i)) do
        map[i]=0
    done
    #先将上底和下底弄成边框
    for(( i=colbegin ; i<colend ; ++i)) do
        Assign $((rowbegin-1)) $i -1
        Assign $((rowend)) $i -1
    done
    #再把左右两边弄成边框
    for(( j = rowbegin;j<rowend;++j))do
        Assign $j $((colbegin-1)) -1
        Assign $j $colend -1
    done
    #再补充上四个角
    Assign $((rowbegin-1)) $((colbegin-1)) -1
    Assign $((rowbegin-1)) $((colend)) -1
    Assign $((rowend)) $((colbegin-1)) -1
    Assign $((rowend)) $((colend)) -1
#    Draw
}
#判断一行是否填满
function CheckRow() {
    row=$1
    local i=0
    for((i = colbegin; i < colend; ++i)) do
        Decode $row $i
        if((map[ret]<=0))
         then
            return 0
        fi
    done
    return 1
}
#删掉一行并平移上面的
function Wash() {
    local i=$1
    local j=0
    for((;i>rowbegin;--i)) do
        for((j = colbegin; j < colend; ++j)) do
        Decode $i $j
        local temp1=$ret
        Decode $((i-1)) $j
        local temp2=$ret
        map[$temp1]=${map[$temp2]}
        #((map[temp1]=map[temp2]))
        done
    done
    
    for((j = colbegin; j < colend; ++j)) do
        Decode $i $j
        local temp1=$ret
        map[$temp1]=0
        done
    Draw
}
#消行操作
function Clean() {
    local i=0
    #记录该次消行行数
    local tot=0
    for(( i = rowbegin; i < rowend; ++i)) do
    #    echo "i=$i"
        CheckRow $i
        if(($? == 1))
         then
           # echo "fuck i = $i"
           ((++tot))
            Wash $i
            ((--i))
        fi
    done
    #如果有消行的话
    if((tot>0))
    then
        #如果不是连续消行
        if((suc==0)) 
        then
            case "$tot" in
            "1")
                    play -q skin/sfx/default/sfx_single.wav &
                    play -q skin/voice/default/01_single.wav &
                    tet=0
                    ((score+=0));;
                    
            "2")
                    play -q skin/sfx/default/sfx_double.wav &
                    play -q skin/voice/default/02_double.wav &
                    tet=0
                    ((score+=1));;
            "3")
                    play -q skin/sfx/default/sfx_triple.wav &
                    play -q skin/voice/default/03_triple.wav &
                    tet=0
                    ((score+=2));;
             
            "4")
                    tet=4
                    play -q skin/sfx/default/sfx_tetris.wav &
                    play -q skin/voice/default/04_tetris.wav &
                    ((score+=4));;
            esac
            else
            case "$tot" in
            "4")
                    if((tet==4))
                    then
                        play -q skin/sfx/default/sfx_b2b_tetris.wavwav &
                         play -q skin/voice/default/05_b2btetris.wav &
                         ((score+=5))
                    fi
                    tet=4
                    play -q skin/sfx/default/sfx_tetris.wav &
                    play -q skin/voice/default/04_tetris.wav &
                    ((score+=4));;
                esac
   
                case "$suc" in
                "1")
                        play -q skin/voice/default/15_combo01.wav &;;
                "2")
                        play -q skin/voice/default/15_combo02.wav &;;

                "3")
                        play -q skin/voice/default/15_combo03.wav &;;
                "4")
                        play -q skin/voice/default/15_combo04.wav &;;
                "5")
                        play -q skin/voice/default/15_combo05.wav &;;
                    esac
                if((suc>5))
                then
                    play -q skin/voice/default/15_combo05.wav &
                fi
         
            if((suc>=1))
            then
                    play -q skin/sfx/default/sfx_combo${suc}.wav &
            fi
            ((score+=${combo[$suc]}))
        
        fi
        ((suc++))
        scoreUpdate
        return
    fi
    suc=0
    scoreUpdate
}
#实现Hold功能
function Hold() {
            
    if ((change>0)) 
    then
    play -q skin/sfx/default/sfx_rotatefail.wav &
        return
    fi
    change=1
    play -q skin/sfx/default/sfx_hold.wav &
    #如果手里现在没有方块，就直接把now的方块丢到inHand里，然后now读取下一个方块
    local len=${#inHand[*]}
    #echo "x=${x}, y=${y}"
    #echo "length=$len"
    if ((len<9))
    then
     #   echo "fuck"
        inHand=0
        inHand=(${now[*]})
        AddInHand $inhandx $inhandy
        Del $nowx $nowy
        GetNextBlock
        CreateNewBlock $nextBLock        
        return
    fi
    #如果手里有方块，那就交换inHand的方块和now的方块
    #echo "有方块"
    DelInHand $inhandx $inhandy
     #echo "${inHand[*]}">>fuck
    
    local tempblock=(${inHand[*]})
    inHand=(${now[*]})
    
    AddInHand $inhandx $inhandy
    Del $nowx $nowy
    now=(${tempblock[*]})
    nowx=3
    nowy=15
    prex=3
    prey=15
    tprex=3
    tprey=15
    Add $nowx $nowy
}
function Run() {
    
    Init
    GetNextBlock
    CreateNewBlock $nextBLock
     Draw
     play -q skin/voice/default/22_ready.wav
    play -q skin/voice/default/23_go.wav &
    # sTTY=`stty -g`
   while [ 1 -eq 1 ] 
    do
         for ((i = 0; i < 50; i++))
            do
                        read -t 0.02 -n 1 -s key 
                        case "$key" in
                        "A")
                        DelGhost $ghostx $ghosty
                            RRotate
                            Ghost;;
                            
                        "B")
                        DelGhost $ghostx $ghosty
                            Move 1
                            Ghost;;
                        "C")
                        DelGhost $ghostx $ghosty
                            Move 3
                            Ghost;;
                        "D")
                        DelGhost $ghostx $ghosty
                            Move 2
                            Ghost;;
                        esac
                        if  [[ $key == "c" ]]
                        then
                            #echo "fuck"
                            DelGhost $ghostx $ghosty
                            Rotate
                            Ghost
                        fi
                        if  [[ $key == "x" ]]
                        then
                            #echo "fuck"
                            play -q skin/sfx/default/sfx_harddrop.wav &
                            DelGhost $ghostx $ghosty
                            AllDown

                        fi
                        if  [[ $key == "z" ]]
                        then
                            #echo "fuck"
                            DelGhost $ghostx $ghosty
                            Hold
                            Ghost
                        fi
                     #   echo "$key"
            done
        Del $tprex $tprey
        Down
        Ghost
        Add $nowx $nowy
       
        tprex=$nowx
        tprey=$nowy
       # Clean
    done
}
#隐藏光标
#演奏BGM

  {  while ((1==1)) 
  do
    play -q skin/music/default/bgm_01.ogg
done } &
bgmPid=$!
trap "kill $bgmPid;clear;exit" SIGINT SIGTERM SIGQUIT SIGHUP SIGSTOP SIGTSTP
#bash $0 --muisc&
echo -ne "\033[?25l"
#取消回显
stty -echo
Run






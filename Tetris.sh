 #totTime 表示每一帧的总时间
 totTime=0
 #startTime 表示当前帧开始时间
 startTime=0
 #ret这个变量用来表示函数的返回值
ret=0 
 #map用来维护界面的信息
O=(1 1 0 1 1 0 0 0 0)
I=(2 2 2 2 0 0 0 0 0 0 0 0 0 0 0 0)
S=(0 3 3 3 3 0 0 0 0)
Z=(4 4 0 0 4 4 0 0 0)
L=(5 0 0 5 0 0 5 5 0)
J=(0 6 0 0 6 0 6 6 0)
T=(7 7 7 0 7 0 0 0 0)
box=(O I S Z L J T)
#now表示正在操作的方块的矩阵状态
now=$O
#pre表示正在操作的方块的矩阵在上一时刻的状态
pre=$O
prex=0
prey=0
#tpre表示正在操作的矩阵在上一次有效操作时的状态
tpre=$O
tprex=0
tprey=0
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
nextBLock=$(($RANDOM %7 + 1))
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
                echo "temp1=${temp1}, temp2=$temp2"
                if ((now[temp1]!=0 && map[temp2]!=0))
       #         (((${now[$temp1]}) != 0 &&  (${map[$temp2]})!= 0)) #如果成立就说明发生了碰撞
                then
                    echo "fuck"
                    crash=1
                    return
                fi
            done
    done
}
#将当前方块逆时针旋转90°
function Rotate() {
    pre=(${now[*]})
    local len=${#now[*]}
  #  echo "len=$len"
    if ((len == 16)) 
    then
        len=4
       # echo "233"
        for((i = 0; i < 4; ++i)) do
            for(( j = 0; j  < 4; ++j )) do
                Trans $i $j $len
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
    Check
    if ((crash==1)) 
    then
        now=(${pre[*]})         #发生碰撞，此次旋转无效
        pre=(${tpre[*]})
    fi
}
#得到下一个方块的种类
function GetNextBlock(){
    nextBLock=$(($RANDOM %7 + 1))
}
#让新的方块出现
function CreateNewBlock(){
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
    Add nowx nowy
    GetNextBlock
    CreateNewBlock $nextBLock
    
}
function Down() {
    echo 233
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
    fi
}
function Left(){
     prex=$nowx
    prey=$nowy
    ((nowy--))
    if ((crash==1)) 
    then
                 #发生碰撞,平移失败
        nowx=$prex
        nowy=$prey
        prex=$tprex
        prey=$tprey
    fi
}
function Right(){
     prex=$nowx
    prey=$nowy
    ((nowy++))
    if ((crash==1)) 
    then
                 #发生碰撞,平移失败
        nowx=$prex
        nowy=$prey
        prex=$tprex
        prey=$tprey
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
                    echo -ne "   ";;
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
                    echo -ne "\e[1;33;42m   \e[0m";;
            esac
        done
            echo ""
    done
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
                 map[$ret]=0
            fi
        done
    done
}
function Init() {
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
function Run() {
    Init
    GetNextBlock
    CreateNewBlock $nextBLock
   while [ 1 -eq 1 ] 
    do
         for ((i = 0; i < 20; i++))
            do
                        sleep 0.02
            done
        Del $tprex $tprey
        Move 1
        Add $nowx $nowy
        Draw
        tprex=$nowx
        tprey=$nowy
    done
}
#隐藏光标
echo -ne "\033[?25l"
Run



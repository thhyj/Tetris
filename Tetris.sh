 #ret这个变量用来表示函数的返回值
ret=0 
 #map用来维护界面的信息
O={1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0}
I={1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0}
S={0,1,1,0,1,1,0,0,0,0,0,0,0,0,0,0}
Z={1,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0}
L={1,0,0,0,1,0,0,0,1,1,0,0,0,0,0,0}
J={0,1,0,0,0,1,0,0,1,1,0,0,0,0,0,0}
T={1,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0}
#now表示正在操作的方块的4*4矩阵状态
now=$O
#pre表示正在操作的方块的4*4矩阵在上一时刻的状态
pre=$O
#-1代表边框

#俄罗斯方块主界面的行列位置
colbegin=10
colend=20
rowbegin=3
rowend=23
#将二维坐标转换为一维编号，x为行号，y为列号
#这是针对4*4的
function Trans() {
    local x=$1
    local y=$2
    ret=$(((x*4)+(y)))
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
    for((i = 0; i < 30; ++i)) do 
        for(( j = 0; j < 30; ++j)) do
            Decode $i $j
            case "${map[$ret]}" in
                "0")
                    echo -ne "\e[1;33;40m   \e[0m";;
                "-1")
                    echo -ne "\e[1;33;44m   \e[0m";;
            esac
        done
            echo ""
    done
}
#把正在操作的方块画进去
function Add() {
    local x=$1
    local y=$2
    for((i = x ; i < x + 4 ; ++i)) do
        for((j = y; j < y + 4; ++j)) do
            Trans $((i - x)) $((j - y))
            echo "ret =  $ret"
            temp=${now[$ret]}
            echo "temp = $temp"
            Decode $i $j
            map[$ret]=temp
        done
    done
}
#把正在操作的方块上一个时刻在的位置擦掉
function Del() {
    local x=$1
    local y=$2
    for((i = x ; i < x + 4 ; ++i)) do
        for((j = y; j < y + 4; ++j)) do
            Trans $((i - x)) $((j - y))
            temp=$now[$ret]
            if ((temp==1)) 
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
    Draw
}

Init
#now=$O
#echo $now
#Add 3 10
#Draw



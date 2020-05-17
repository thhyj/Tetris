while ((1==1)) 
 do
read -t 0.01 -n 1 -s key 
case "$key" in
"A")
 echo "1" >>up;;
"B")
 echo "1" >>down;;
"C")
 echo "1" >>right;;
"D")
 echo "1" >>left;;
esac
sleep 0.1
done
} &
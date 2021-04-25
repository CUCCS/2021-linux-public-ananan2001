#!/usr/bin/env bash
help() 
    {
    cat << EOF

    Desc:   该程序作用是能对数据文件进行批量处理，完成数据统计工作。
    Usage:  bash $0 [-a] [-p] [-n] [-m] [-h]
    Author: ananan2001
    options：
        -h 帮助文档
        -t 统计访问来源主机TOP 100和分别对应出现的总次数
        -i 统计访问来源主机TOP 100 IP和分别对应出现的总次数
        -u 统计最频繁被访问的URL TOP 100
        -p 统计不同响应状态码的出现次数和对应百分比
        -a 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
        -s 输出给定URL访问Top100的来源主机
EOF
        exit 0
    }

# 统计访问来源主机TOP 100和分别对应出现的总次数
TOP100(){
    awk -F '\t' '{
        print "访问来源主机TOP 100和分别对应出现的总次数\n"}
                {print $1}'
    web_log.tsv  | sort | -k1 -rg | head -100
}

# 统计访问来源主机TOP 100 IP和分别对应出现的总次数
TOP100IP(){
    awk -F '\t' '{
                print "统计访问来源主机TOP 100 IP和分别对应出现的总次数\n" }
                {
                if(($1~/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/){print $1}}' 
    web_log.tsv | sort | uniq -c | sort -nr | head -n 100  
 }


# 统计最频繁被访问的URL TOP 100
TOP100url(){    
    awk -F '\t' '{
        print "统计最频繁被访问的URL TOP 100:\n"
        }
        {
            print $5 "\n\n"}' 
    web_log.tsv |sort | uniq -c|sort -nr|head -n 100
}

# 统计不同响应状态码的出现次数和对应百分比
percentage_of_different_states(){
    printf "|相应状态码类型|出现次数|百分比|\n"
    awk -F '\t' 'BEGIN{sum=0}
    NR>1{
        a[$6]++;
    }
    sum++;
    END{
        for( state in states ){
            printf("%s\t%d\t%.6f\t\n",state,states[state],state[state]/sum) 
        }
    }' web_log.tsv
}

# 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
TOP10_4XXstates(){
    printf "|TOP10的4XX状态码|出现次数|出现该现象的网址|\n"
    awk -F '\t' ' {
        print "403"
        }
        {
            if($6==403)
            {
                print $5,"\n\n"}
                }' web_log.tsv  | sort | uniq -c| sort -nr|head -n 12
    awk -f '\t' ' {
        print "404"}
        {
            if($6==404)
            {
                print $5,"\n\n"}
                }' web_log.tsv  | sort | uniq -c| sort -nr|head -n 12
}

# 给定URL输出Top100访问的来源主机
SRCHOST(){ 
    printf "|访问次数|来源主机|\n"
    awk -F '\t' '
    NR>1{
        if(url==$5){
            print $1  "\n\n"
        }
    }
    ' web_log.tsv | sort | uniq -c | sort -nr | head -n 100
    exit 0
}

while [-n "$1"];do
    case $1 in
        -h) help;;
        --) shift;break;;
        -t) TOP100;;
        -i) TOP100IP;;
        -u) TOP100url;;
        -p) percentage_of_different_state;;
        -a) TOP10_4XXstates;;
        -s) SRCHOST;;
        -*) echo"error:no such option $1.";exit 1;;
        *0) break;;
    esac
    done
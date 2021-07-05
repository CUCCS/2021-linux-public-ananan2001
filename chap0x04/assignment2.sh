#!/usr/bin/env bash
help() 
    {
    cat << EOF
    Desc:   该程序作用是能对数据文件进行批量处理，完成数据统计工作。
    Usage:  bash $0 [-a] [-p] [-n] [-m] [-h]
    Author: ananan2001
    options：
        -h 帮助文档
        -a 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
        -p 统计不同场上位置的球员数量、百分比
        -n 名字最长的球员是谁？名字最短的球员是谁？
        -e 年龄最大的球员是谁？年龄最小的球员是谁？
EOF
        exit 0
    }

File="worldcupplayerinfo.tsv"

#统计功能一：统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
age_count{
    awk -F "\t" '
        BEGIN {a=0; b=0; c=0;}
        $6!="Age" {
            if($6<20) {a++;}
            else if($6<=30) {b++;}
            else {c++;}
        }
        END {
            sum=a+b+c;
            printf("统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比\n");
            printf("年龄\t数量\t百分比\n");
            printf("20-\t%d\t%f%%\n",a,a*100.0/sum);
            printf("[20,30]\t%d\t%f%%\n",b,b*100.0/sum);
            printf("30+\t%d\t%f%%\n",c,c*100.0/sum);
        }' "$File"
        return
}

#统计功能二：统计不同场上位置的球员数量、百分比
position_count{
    awk -F "\t" '
        BEGIN {sum=0}
        $5!="Position" {
            positions[$5]++;
            sum++;
        }
        END {
            printf("统计不同场上位置的球员数量、百分比\n");
            printf("位置\t数量\t百分比\n");
            for(p in positions) {
                printf("%13s\t%d\t%f%%\n",i,positions[i],positions[i]*100.0/sum);
            }
        }' $File
}

#统计功能三：名字最长的球员是谁？名字最短的球员是谁？
name_length_extremum {
    awk -F "\t" '
        BEGIN {max=0;min=100}
        $9!="Player" {
            len=length($9);
            names[$9]=len;
            max=len>max?len:max;
            min=len<min?len:min;
        }
        END {
            for(name in names) {
                if(names[name]==max) {
                    printf("名字最长的球员是%s.\n", name);
                } else  if(names[name]==min) {
                    printf("名字最短的球员是%s.\n", name);
                }
            }
        }' $File
}

# 统计功能四：年龄最大的球员是谁？年龄最小的球员是谁？
age_extremum {
    awk -F "\t" '
        BEGIN {max=-1; min=999;}
        $6!="Age"  {
            age=$6;
            names[$9]=age;
            max=age>max?age:max;
            min=age<min?age:min;
        }
        END {
            printf("年龄最大的球员是\t.", max);
            for(name in names) {
                if(names[name]==max) { printf("%s\n", name); }
            }
            printf("年龄最小的球员是\t.", min);
            for(i in names) {
                if(names[name]==min) { printf("%s\n", name); }
            }
        }' $File
}

while [-n "$1"];do
    case $1 in
        -h) help;;
        --) shift;break;;
        -a) age_count;;
        -p) position_count;;
        -n) name_length_extremum;;
        -e) age_extremum;;
        -*) echo"error:no such option $1.";exit 1;;
        *0) break;;
    esac
    done
#!/usr/bin/env bash

help() 
    {
    cat << EOF
    Desc:   该程序是一个图片批处理脚本，能实现要求所述的5个功能。
    Usage:  bash $0 [-q] [-r] [-w] [-p] [-s] [-t] 
    Author: ananan2001
    options：
        -h      帮助文档
        -q Q    以参数Q为质量因子进行JPEG图片压缩
        -r R    以参数r为分辨率压缩 jpeg/png/svg 图像
        -w      自定义添加水印
        -p      批量加前缀
        -s      批量加后缀
        -t      将 png/svg 图片转换为 jpg 格式图像
EOF
        exit 0
    }

# 功能一：对jpeg格式图片进行图片质量压缩
JPEG_quality_compress {
    Q=$1
    for i in $(ls *.jpeg); do
        convert "$i" -quality "$Q" "$i"
        echo "$i 已压缩 $Q。"
    done
}

# 功能二：对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率
distinguish_compress {
    D=$1
    for i in $(ls *.jpeg *.png *.svg);do
        convert "$i" -resize "$D" "$i"
        echo "$i 已压缩 $D 分辨率 。"
    done
}

# 功能三：对图片批量添加自定义文本水印
add_watermarking {
    for i in *;do
        convert "$i" -pointsize "$1" -fill black -gravity southeast  -draw "text 10,20 '$2'" "$i"
        echo "$i 添加自定义水印 $2 完毕。"
    done
}

# 功能四（一）：统一添加文件名前缀,不影响原始文件扩展名）
add_prefix {
    for i in *;do
        mv $i $1$i
        echo "已添加 $i 的前缀名 $1。"
    done
}

# 功能四（二）：统一添加文件名后缀,不影响原始文件扩展名）
add_suffix {
    for i in *;do
        mv $i $i$1
        echo "已添加 $i 的后缀名 $1。"
    done
}

# 功能五：将png/svg图片统一转换为jpg格式图片
transform_into_jpg {
    for i in $(ls *.png &.svg); do
        convert $i $(img%.*).jpg
   	echo "$i 已转换为jpg格式。"
    done
}

while [-n "$1"];do
    case $1 in
        -h) help;;
        --) shift;break;;
        -q) JPEG_quality_compress "$2" "$3";;
        -r) distinguish_compress "$2" "$3";;
        -w) add_watermarking "$2" "$3";; 
        -p) add_prefix "$2";; 
        -s) add_suffix "$2";; 
        -t) transform_into_jpg;; 
        -*) echo"error:no such option $1.";exit 1;;
        *0) break;;
    esac
    done
    

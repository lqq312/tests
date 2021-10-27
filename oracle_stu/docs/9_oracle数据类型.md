[TOC]

# oracle的数据类型

官方文档：SQL Language Reference --> 2.1 Data Types

## varchar2

可变长度类型；

MAX_STRING_SIZE=STANDARD：最大4000字节或字符；
MAX_STRING_SIZE=EXTENDED：最大32767字节或字符；

```
    SQL> show parameter max_string;

        NAME                                 TYPE        VALUE
        ------------------------------------ ----------- ------------------------------
        max_string_size                      string      STANDARD
```

## char

固定长度，最大2000字节或字符；
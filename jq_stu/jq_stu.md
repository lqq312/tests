[TOC]

# 简介
jq是用于命令行的JSON解析器；jq可以通过多种不同的方式（JSON文件或从stding读取JSON数据流）转换JSON文档；

jq的语法：

    `jq [options...] filter [files...]`

jq程序本质上是一个”过滤器“，其内部有许多内置的过滤器用于提取对象的特定字段，或将数字转换为字符串，或执行各种其他标准任务。也可以组合多个过滤器（将一个过滤器的输出通过管道送至另一个过滤器中或者将一个过滤器的输出收集到一个数组中）；
有些过滤器会产生多个结果，例如有一个过滤器产生它的输入数组的所有元素，将过滤器插入至第二个过滤器的管道，为数组中的每个元素运行第二个过滤器。在其他语言中需要使用循环和迭代来完成的事情在jq中只需要将过滤器粘合在一起即可；

# jq选项

测试的JSON文档：

```
shell> curl -s 'http://localhost:9090/api/v1/query?query=Topic_LAG'
{"status":"success","data":{"resultType":"vector","result":[{"metric":{"GroupId":"iov-message-server","ProgramName":"tiisp2020","TopicName":"AlarmInfo","__name__":"Topic_LAG","exported_job":"BusinessMonitor","instance":"10.167.1.246:9091","job":"custom_monitor"},"value":[1609215358.03,"11"]},{"metric":{"GroupId":"dataCenter-20201116","ProgramName":"tiisp2020","TopicName":"T808-0200-1","__name__":"Topic_LAG","exported_job":"BusinessMonitor","instance":"10.167.1.246:9091","job":"custom_monitor"},"value":[1609215358.03,"42"]}]}}
```

## 选项
```
--version：查看jq的版本
    shell> jq --version
        jq-1.6

--slurp/-s：将读到的数据流组织为一个数组

--raw-input/-R：不作为JSON解析，将每一行的文本作为字符串输出到屏幕（将JSON文档转换为一行数据，会在换行的地方加上”\“表示换行）
    shell> curl -s 'http://localhost:9090/api/v1/query?query=Topic_LAG' | jq -R
        "{\"status\":\"success\",\"data\":{\"resultType\":\"vector\",\"result\":[{\"metric\":{\"GroupId\":\"iov-message-server\",\"ProgramName\":\"tiisp2020\",\"TopicName\":\"AlarmInfo\",\"__name__\":\"Topic_LAG\",\"exported_job\":\"BusinessMonitor\",\"instance\":\"10.167.1.246:9091\",\"job\":\"custom_monitor\"},\"value\":[1609211908.733,\"16\"]},{\"metric\":{\"GroupId\":\"dataCenter-20201116\",\"ProgramName\":\"tiisp2020\",\"TopicName\":\"T808-0200-1\",\"__name__\":\"Topic_LAG\",\"exported_job\":\"BusinessMonitor\",\"instance\":\"10.167.1.246:9091\",\"job\":\"custom_monitor\"},\"value\":[1609211908.733,\"67\"]}]}}"

--compact-output /-c：使输出紧凑，而不是把每一个JSON对象输出在一行
    shell> curl -s 'http://localhost:9090/api/v1/query?query=Topic_LAG' | jq -c
        {"status":"success","data":{"resultType":"vector","result":[{"metric":{"GroupId":"iov-message-server","ProgramName":"tiisp2020","TopicName":"AlarmInfo","__name__":"Topic_LAG","exported_job":"BusinessMonitor","instance":"10.167.1.246:9091","job":"custom_monitor"},"value":[1609214673.007,"13"]},{"metric":{"GroupId":"dataCenter-20201116","ProgramName":"tiisp2020","TopicName":"T808-0200-1","__name__":"Topic_LAG","exported_job":"BusinessMonitor","instance":"10.167.1.246:9091","job":"custom_monitor"},"value":[1609214673.007,"40"]}]}}

--colour-output / -C：打开颜色显示

--monochrome-output / -M：关闭颜色显示

--ascii-output /-a：指定输出格式为ASCII

--tab：使用tab替换空格

--raw-output /-r ：如果过滤的结果是一个字符串，那么直接写到标准输出（去掉字符串的引号）
    shell> curl -s 'http://localhost:9090/api/v1/query?query=Topic_LAG' | jq -r '.data.result[1].value'[1]
        57

--sort-keys / -S：按指定的key进行排序

```

## 过滤器

```
. ：默认输出

.foo：输出指定属性的值

.[foo]：输出数组内的指定元素的值，foo表示数组的下标；

.[1:2]：输出数组内部分元素的值；

[]：输出指定数组内的全部元素；

, ：指定多个属性作为过滤条件时，用逗号分隔；
    shell> curl -s 'http://localhost:9090/api/v1/query?query=Topic_LAG' | jq '.data.result[1].metric | {GroupId,TopicName}'
        {
          "GroupId": "dataCenter-20201116",
          "TopicName": "T808-0200-1"
        }

| ：将指定的数组的元素中的某个属性作为过滤条件
    shell> curl -s 'http://localhost:9090/api/v1/query?query=Topic_LAG' | jq '[.data.result[] | {GroupId:.metric.GroupId,value:.value[1]}]'
        [
          {
            "GroupId": "iov-message-server",
            "value": "11"
          },
          {
            "GroupId": "dataCenter-20201116",
            "value": "49"
          }
        ]
```

## 内置函数与操作符

```
length：显示对象的长度，如果对象是字符串则显示字符串的个数，如果对象是数组则显示数组内元素的个数，如果对象是数字则显示数字，如果键值对则显示键值对的个数；
    shell> curl -s 'http://localhost:9090/api/v1/query?query=Topic_LAG' | jq -r '.data.result | length'
        2

keys：以数组的方式显示对象内部的key；
    shell> curl -s 'http://localhost:9090/api/v1/query?query=Topic_LAG' | jq -r '.data.result[] | keys'
        [
          "metric",
          "value"
        ]
        [
          "metric",
          "value"
        ]

select：查询指定key的值；
    shell> curl -s 'http://localhost:9090/api/v1/query?query=Topic_LAG' | jq -r '.data.result[] | select(.metric.GroupId == "iov-message-server") | .value[1]'
        18
```

## 条件表达式

```
if-the-else：`if A then B else C end`或`if A then B end`

>，>=，<=，<

==，!=

and / or / not
```

## 正则表达式

```
默认只匹配第一个被模式匹配到的字符串
STRING | FILTER( REGEX )
STRING | FILTER( REGEX; FLAGS )
STRING | FILTER( [REGEX] )
STRING | FILTER( [REGEX, FLAGS] )

常用FLAGS：
g - 全局检索
i - 忽略大小写
m - 检索多行内的数据
n - 忽略没有匹配到的内容
p - 等同于同时使用s和m模式
s - 单行模式
l - Find longest possible matches
x - Extended regex format (ignore whitespace and comments)
```
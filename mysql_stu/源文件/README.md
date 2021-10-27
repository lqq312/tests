[TOC]

#一级标题
##二级标题
###三级标题

**加粗**

*斜体*

***加粗&斜体***

~~删除线~~

<u>下划线</u>

<span style="color:red">红色文本</span>

<span style="color:green">绿色文本</span>

[说明，也可以是文本内容，锚点](#jump1)

生成一个脚注[^1]

---------------------

>引用1
>引用2
>
>>二级引用
>>
>>>三级引用

无序列表：（使用“*”、“+”、“-”均可）

* 无序列表1
* 无序列表2
* 无序列表3

有序列表：

1. 有序列表1
2. 有序列表2
3. 有序列表3

任务清单：

- [ ] 任务1
- [ ] 任务2
- [X] 任务3

----------------

极简表格：

name | 价格 | 数量
- | - | -
香蕉 | $1 | 5
苹果 | $1 | 6
草莓 | $1 | 7

表格对齐：

居中对齐 | 左对齐 | 右对齐
:-: | :- | -:
abc | cba | abcd

单行代码：

`单行代码`

代码块：

```
代码内容
```



<span id="jump1">
跳转到这个地方
</span>

[^1]: 测试脚注


B+ TREE

1. The primary value of a B+ tree is in storing data for efficient retrieval in a block-oriented storage context-in particular, filesystems.
2. In contrast to a B-tree, "all records" are stored at the leaf level of the tree; only keys are stored in interior nodes.
3. B+ trees have very high fanout (typically on the order of 100 or more), which reduces the number of I/O operations required to find an element in the tree.


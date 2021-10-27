[TOC]

# prometheus基础

![prometheus_框架1](/Users/luqq/Documents/02_tec-doc/prometheus/pic/prometheus_框架1.jpeg)

Grafana：绘图工具，prometheus自身已有绘制图形的能力，但grafana绘制的图形更精确，更美观。

Pagerduty：收费的报警系统

Prometheus的优势：

1. 监控数据的精度高，理论上可精确到1～5秒；
2. 集群部署的速度快；
3. 周边插件很丰富，大多数都不需自己开发；
4. 本身基于数据计算模型，有大量实用的函数，可以实现很复杂规则的业务逻辑监控；
5. 可以嵌入很多开源工具的内部进行监控，数据更准时，更可信；
6. 本身开源，更新速度更快，bug修复快，支持多种语言实现其自身和插件的二次开发；
7. 与grafana结合后展示的图形很美观。



监控项目：

1. 业务监控：用户访问QPS、DAU日活、访问状态、业务接口（登陆、注册、聊天、上传、留言、短信、搜索）、产品转化率、用户投诉等；
2. 系统监控：主要是跟操作系统相关的基本监控项，CPU、内存、硬盘、I/O、TCP连接、流量等；
3. 网络监控：对网络状态的监控，丢包率、延迟等；
4. 日志监控：监控中的重头戏（Splunk，ELK），往往单独设计和搭建，全部种类的日志都有采集；
5. 程序监控：一般需要和开发人员配合，程序中嵌入各种接口直接获取数据或者特质的日志格式。



未来监控体系：

1. 完整自愈式监控体系：监控和报警在自愈系统下各种层级的问题都会被自动化、持续集成、人工智能、灾备、系统缓冲等技术自行修复（docker，kubernetes）。
2. 真实链路式监控：监控和报警的准确性、真实性发展到最终的一个理想化模型。

![prometheus体系架构](/Users/luqq/Documents/02_tec-doc/prometheus/pic/prometheus架构.png)

Prometheus监控的体质特性：

1. 基于time series时间序列模型，时间序列是一系列有序的数据，通常是等时间间隔的采样数据；
2. prometheus的本地T-S（Time Series）数据库以每两个小时为间隔来划分block（块）来存储，每个块中又分为多个chunk文件，chunk文件是用来存放采集过来的数据的T-S数据、metadata和索引（index）。
3. index文件是对metrics（prometheus中一次k/v采集数据叫做一个metric）和labels（标签）进行索引，然后存储在chunk中，chunk是作为存储的基本单位，index和metadata是作为其子集。
4. 基于K/V的数据模型，例如：{disk_size: 80 }，其数据格式简单，速度快，易于维护；
5. 采样的数据的查询完全基于数学运算而不是其他的表达式，并提供专有的查询输入console，所有的查询都基于数学运算公式；
6. 采用HTTP pull/push两种对应的数据采集传输方式，所有的数据采集都基本采用HTTP，而且分为pull/push两种方式去写/采集程序；
7. push方法灵活，push的这种采集方法可采集几乎任何形式的数据；
8. 本身自带图形调试，可方便运维进行调试，但最终还是要与其他图形化展示的插件进行结合（如grafana）；
9. 最精细的数据采样，prometheus理论上可以达到每秒采集，可自行定义频率。

## prometheus的数据类型

prometheus本身是一个以进程的方式启动，之后以多进程和多线程的方式实现监控数据收集、计算、查询、更新和存储的一种C/S架构模型。

prometheus监控中对于采集过来的数据统一称为metrics数据，metrice是一种对采样数据的总称（metrics并不代表某一种具体的数据格式，是一种对于试题计算单位的抽象）。

metrics的几种主要类型：

1. Gauges，最简单的度量指标，只有一个简单的返回值，或者叫瞬时状态，例如：要监控硬 容量或者内存的使用量，就应该使用Gauges或者metrics格式来度量（因为硬盘的容量或者内存的容量是随着时间的推移不断的瞬时变化的，这种变化没有规律，当前是多少采集回来的就是多少这是没有规律的）。
2. counters，计数器，从数据量0开始累积计算，在理想状态下counters只能永远不会下降，例如用户访问量只会增加或保持不变而不会减少（例如网卡发出的字节数、当日累计访问数）。
3. Histograms，统计数据分布情况，比如最小值，最大值，中间值，还有中位数，这一种特殊的metrics数据类型，代表一种近似的百分比估算数值，此种数据类型在实际使用中应用性较强（如：将HTTP的响应时间按比例予以显示，例如0.5秒以下的有多少，0.5～1秒的有多少等）。



Key-Value数据的形式：

prometheus的数据类型就是依赖于这种metrics的类型计算出来的，metrics是由exporter（例如node_exporter）在服务器上采集来的服务器上的Key/Value类型的metrics数据；当一个exporter被安装和运行在被监控的服务器上之后，使用简单的curl命令就可以看到exporter采集到的metrics数据的样子，以key/value的形式展现和保存

```
shell# curl localhost:9100/metrics
```

以#开头的即为对数据的注释。



## exporter介绍

* blackbox_exporter
* Haproxy_exporter
* Node_exporter
* Statsd_exporter

大多数exporters下载后，就提供了启动的命令，一般直接运行，带上一些参数即可。

最常用的即为node_exporter，几乎可以把Linux系统中和系统相关的监控数据全都抓取出来。

## pushgateway

exporter是安装在被监控的服务器上运行在后台，然后自动采集系统数据，本身又是一个HTTP_server可以被prometheus服务器定时去HTTP GET取得数据，属于pull的形式，pushgateway就是相反的过程，pushgateway安装在客户端或服务端均可，pushgateway本身也是一个http服务器，运维通过写自己的脚本程序抓自己想要的监控数据，然后将数据上传到pushgateway上再由pushgateway推送到prometheus服务端。

* exporter虽然采集类型已经很丰富了，但我们仍需要很多自制的监控数据；
* exporter由于数据类型采集量大，而很多数据在实际应用中用不到，而使用pushgateway是定义一项数据就可以采集一种，可以大量节省资源。

# Prometheus安装与基本使用

![监控01](/Users/luqq/Documents/02_tec-doc/prometheus/pic/监控01.png)

## prometheus安装步骤

```
shell> chronyc -c makestep
shell> wget -P /root https://github.com/prometheus/prometheus/releases/download/v2.17.1/prometheus-2.17.1.linux-amd64.tar.gz
shell> tar axf /root/prometheus-2.17.1.linux-amd64.tar.gz -C /usr/local
shell> cd /usr/local
shell> tar axf prometheus-2.17.1.linux-amd64 prometheus
shell> cd /usr/local/prometheus
shell> vim startup.sh
	/usr/local/prometheus/prometheus --config.file="/usr/local/prometheus/prometheus.yml" --web.listen-address="0.0.0.0:9090" --web.read-timeout=5m --web.max-connections=10 --storage.tsdb.retention=15d --storage.tsdb.path="/us
r/local/prometheus/data" --query.max-concurrency=20 --query.timeout=2m
shell> chmod +x startup.sh

shell> wget -P /root http://local-yum.ycigilink.local/Softwares/daemonize/daemonize-release-1.7.8.tar.gz
shell> tar axf /root/daemonize-release-1.7.8.tar.gz -C /usr/local/src
shell> cd /usr/local/src/daemonize-release-1.7.8
shell> ./configure && make && make install

shell> daemonize -c /usr/local/prometheus /usr/local/prometheus/startup.sh
```

### Prometheus常用选项

#### 存储常用选项

1. `--storage.tsdb.path`: 这决定了Prometheus把数据库写在哪里。默认为 `data/`。
2. `--storage.tsdb.retention.time`: 这将决定何时删除旧数据。默认为`15d`。
3. `--storage.tsdb.wal-compression`: 此选项启用write-ahead日志（WAL）压缩。如果你启用了这个选项，并随后将Prometheus降级到2.11.0以下的版本，你将需要删除WAL，因为它将无法读取。

Prometheus平均每个采样只使用1-2个字节。因此，要计划一台Prometheus服务器的容量，你可以使用一个粗略的公式：

```
needed_disk_space = retention_time_seconds * ingested_samples_per_second * bytes_per_sample
```



## prometheus主配置文件

```
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
    - targets: ['localhost:9090']
```

Global：定义全局配置；

scrape_interval：定义抓取采样数据的时间间隔，默认每隔15s去被监控主机上采样一次。

evaluation_interval：监控数据规则的评估频率，主要用于监控阈值的评估。

scrape_configs：定义prometheus自身的配置。

Job_name：定义监控任务。

targets：定义被监控的机器，此处是一个数组，可在该数组中定义多个被监控主机。

## 服务发现

以Consul为例，prometheus是通过配置文件来给prometheus定义被监控的项目和被监控节点，

```
  - job_name: 'prometheus'
  	static_configs:
  	  - targets: ['prometheus.server:9090','prometheus.server:9100']
  - job_name: 'pushgateway'
  	static_configs:
  	  - targets: ['localhost:9091','localhost:9092']
```

job_name：对应一个任务名称，然后在这个“job_name”之下具体定义要被监控的节点以及节点上具体的端口信息等。



如果prometheus结合了consul这种服务发现软件，prometheus的配置文件就不再需要人工进行定义，而是可以自动发现集群中有哪些新的机器，以及新的机器上出现了哪些新的服务可以被监控。

## prometheus采集客户端

prometheus主要有两种采集方式：

* pull，主动拉取的形式；即被监控机器先安装好各类已有的exporters，exporters以守护进程的方式运行并开始采集数据，而exporter本身也是一个http_server，可以对http请求作出响应返回数据。
* push，被动推送的形式；在被监控机器（或其他机器）上安装好pushgateway插件，然后将运维开发的各种脚本把监控数据组织成k/v或metrics的形式发送给pushgateway，再由pushgateway推送给prometheus。



## prometheus常用函数

increase()：在prometheus中是用于针对Counter这种持续增长的数值，截取一段时间的增量。

`increase(node_cpu_seconds_total[1m])`

即可获取“node_cpu_seconds_total”在1分钟内的差值。



sum()：对函数内的数值进行求和，但会对匹配的所有机器的该指标数据进行加和。

`sum(increase(node_cpu_seconds_total{mode="idle"}[30s]))`

即可对多核CPU的30秒内“idle”的CPU的时间进行加和。



`( 1- sum(increase(node_cpu_seconds_total{mode="idle"}[30s]))/sum(increase(node_cpu_seconds_total[30s]))) * 100`

以上即为30秒内CPU使用率。



by(instance)：把sum加和到一起的数值按照指定的一个方式进行拆分，“instance”即表示机器名。

`( 1- sum(increase(node_cpu_seconds_total{mode="idle"}[30s])) by(instance) /sum(increase(node_cpu_seconds_total[30s])) by(instance)) * 100`

![instance01](/Users/luqq/Documents/02_tec-doc/prometheus/pic/instance01.png)

![instance02](/Users/luqq/Documents/02_tec-doc/prometheus/pic/instance02.png)

exported_instance="xxx"：用于定义展示出的匹配标签的数据。

exported_instance=～"xxx"：用于匹配正则表达式。



rate()：专门用于搭配counter类型的数据使用的函数，其功能是按照设置的一个时间段，取出counter在这个时间段中平均每秒的变化。

`rate(node_network_receive_bytes_total{device="ens32"}[30s])`

![counter01](/Users/luqq/Documents/02_tec-doc/prometheus/pic/counter01.png)

如需获取概要数据可使用increase()函数，而如果获取精细数据则应该使用rate()函数进行处理。

## PromQL表达式

### 表达式语言数据类型

在Prometheus的表达式语言中，任何表达式或者子表达式都可以归为四种类型：

* `instant vector` 瞬时向量 - 它是指在同一时刻，抓取的所有度量指标数据。这些度量指标数据的key都是相同的，也即相同的时间戳；
* `range vector` 范围向量 - 它是指在任何一个时间范围内，抓取的所有度量指标数据；
* `scalar` 标量 - 一个简单的浮点值；
* `string` 字符串 - 一个当前没有被使用的简单字符串。

### 字面量

#### 字符串字面量

PromQL遵循与Go相同的[转义规则](https://links.jianshu.com/go?to=https%3A%2F%2Fgolang.org%2Fref%2Fspec%23String_literals)。在单引号，双引号中，反斜杠成为了转义字符，后面可以跟着`a`,`b`, `f`, `n`, `r`, `t`, `v`或者`\`。 可以使用八进制(`\nnn`)或者十六进制(`\xnn`, `\unnnn`和`\Unnnnnnnn`)提供特定字符。

在反引号内不处理转义字符。与Go不同，Prom不会丢弃反引号中的换行符。例如：

![字符串转义](/Users/luqq/Documents/02_tec-doc/prometheus/pic/promQL01.png)

![字符串转义](/Users/luqq/Documents/02_tec-doc/prometheus/pic/promQL02.png)

#### 浮点数字面量

标量浮点值可以直接写成形式`[-](digits)[.(digits)]`。

### 时间序列选择器

#### 瞬时向量选择器

瞬时向量选择器允许在给定时间戳（即时）为每个选择一组时间序列和单个样本值：在最简单的形式中，仅指定度量名称。 这会生成包含具有此度量标准名称的所有时间序列的元素的即时向量。

下面这个例子选择所有时间序列度量名称为`node_filesystem_free_bytes`的样本数据：

![瞬时向量](/Users/luqq/Documents/02_tec-doc/prometheus/pic/promQL03.png)

通过在度量指标后面增加“{}”一组标签可以进一步过滤这些时间序列中的数据。

此示例仅选择具有`node_filesystem_free_bytes`度量标准名称的时间系列，将文件系统类型设置为`rootfs`。

![瞬时向量](/Users/luqq/Documents/02_tec-doc/prometheus/pic/promQL04.png)

标签的匹配规则如下：

* `=`：精确匹配给定的值；
* `!=`：不等于给定的标签值；
* `=～`：匹配给定的正则表达式的值；
* `!~`：不匹配给定的正则表达式的值。

匹配空标签值的标签匹配器也可以选择没有设置任何标签的所有时间序列数据。正则表达式完全匹配。可以为同一标签名称提供多个匹配器。

向量选择器必需指定一个名称或至少一个与空字符串不匹配的标签选择器。如下的表达式是**非法**的：

![瞬时向量](/Users/luqq/Documents/02_tec-doc/prometheus/pic/promQL05.png)

注意：以上表达式中的正则表达式可以匹配到空字符串，因此为非法表达式。

只要能匹配到一个非空的选择器，即可：

![瞬时向量](/Users/luqq/Documents/02_tec-doc/prometheus/pic/promQL06.png)

#### 范围向量选择器

范围向量文字像即时向量文字一样工作，除了它们从当前时刻选择一系列样本。 在语法上，范围持续时间附加在向量选择器末尾的方括号（`[]`）中，以指定应为每个结果范围向量元素提取多长时间值。

持续时间指定为数字，紧接着是以下单位之一：

* `s` - seconds
* `m` - minutes
* `h` - hours
* `d` - days
* `w` - weeks
* `y` - years

在以下示例中，获取45秒内idle类型的CPU的使用时间：

![范围向量](/Users/luqq/Documents/02_tec-doc/prometheus/pic/promQL07.png)

#### 偏移修饰符

使用`offset`偏移修饰符允许在查询中改变单个瞬时向量和范围向量中的时间偏移。

例如，以下表达式返回过去相对于当前查询评估时间5分钟的`http_requests_total`值：

![范围向量](/Users/luqq/Documents/02_tec-doc/prometheus/pic/promQL08.png)

以下表达式用于计算5分钟前处于idle模式下的名CPU的时间之和：

![范围向量](/Users/luqq/Documents/02_tec-doc/prometheus/pic/promQL09.png)

## PromQL操作符

### 二元操作符

Prometheus的查询语言支持基本的逻辑运算和算术运算。对于两个瞬时向量, [匹配行为](https://prometheus.io/docs/querying/operators/#vector-matching)可以被改变。

#### 算术二元运算符

* `+` 加法
* `-` 减法
* `*` 乘法
* `/` 除法
* `%` 取模
* `^` 幂等

二元运算操作符定义在`scalar/scalar(标量/标量)`、`vector/scalar(向量/标量)`、和`vector/vector(向量/向量)`之间。

#### 比较二元操作符

* `==` 
* `!=`
* `>`
* `<`
* `>=`
* `<=`

比较二元操作符定义在`scalar/scalar（标量/标量）`、`vector/scalar(向量/标量)`，和`vector/vector（向量/向量）`。默认情况下他们过滤。 可以通过在运算符之后提供`bool`来修改它们的行为，这将为值返回`0`或`1`而不是过滤。

* `scalar/scalar`在两个标量之间，必须提供`bool`修饰符，并且这些运算符会产生另一个标量，即`0`（假）或`1`（真），具体取决于比较结果。
* `vector/scalar` 在瞬时向量和标量之间，将这些运算符应用于向量中的每个数据样本的值，并且从结果向量中删除比较结果为假的向量元素。 如果提供了`bool`修饰符，则将被删除的向量元素的值为`0`，而将保留的向量元素的值为1。
* `vector/vector` 在两个瞬时向量之间，这些运算符默认表现为过滤器，应用于匹配条目。 表达式不正确或在表达式的另一侧找不到匹配项的向量元素将从结果中删除，而其他元素将传播到具有其原始（左侧）度量标准名称的结果向量中 标签值。 如果提供了`bool`修饰符，则已经删除的向量元素的值为`0`，而保留的向量元素的值为`1`，左侧标签值为`1`。

#### 逻辑/集合二元操作符

* `and` 交集
* `or` 并集
* `unless` 补集

`vector1 and vector2`得到一个由`vector1`元素组成的向量，其中`vector2`中的元素具有完全匹配的标签集。 其他元素被删除。 度量标准名称和值从左侧向量转移。

`vector1 or vector2`得到包含`vector1`的所有原始元素（标签集+值）的向量以及`vector2`中`vector1`中没有匹配标签集的所有元素。

`vector1 unless vector2`得到一个由`vector1`元素组成的向量，其中`vector2`中没有元素，具有完全匹配的标签集。 两个向量中的所有匹配元素都被删除。

### 聚合运算符

Prometheus支持以下内置聚合运算符，这些运算符可用于聚合单个即时向量的元素，从而生成具有聚合值的较少元素的新向量：

* `sum` 在维度上求和
* `max` 在维度上求最大值
* `min` 在维度上求最小值
* `avg` 在维度上求平均值
* `stddev` 求标准差（表示的也是数据点的离散程度；其在数学上定义为方差的平方根）
* `stdvar` 求方差（表示随机变量和其平均值之间的偏离程序）
* `count` 统计向量元素的个数
* `count_values` 统计相同数据值的元素的数量
* `bottomk` 样本值第K个最小值
* `topk` 样本值每K个最大值
* `quantile` 统计分位数

以上运算符可以用于聚合所有标签维度，也可以通过包含`without`或`by`子句来保留不同的维度。

`<aggr-op>([parameter,] <vector expr>) [without | by (<label list>)] [keep_common]`

* 只有 `count_values`、 `quantile`、 `topk` 和 `bottomk`需要`parameter`。`without` 从结果向量中删除列出的标签，而保留输出的所有其他标签。`by`执行相反的操作并删除不在`by`子句中列出的标签，即使它们的标签值在向量的所有元素之间是相同的。
* `count_values` 为每个唯一采样值输出一个时间序列。每个时间系列都有一个额外的标签。该标签的名称由聚合参数提供，标签值是惟一采样值。每个时间序列的值就是采样值出现的次数。
* `topk`和`bottomk`与其他聚合器的不同之处在于，在结果向量中返回了输入采样的子集，包括原始标签。`by`和`without`只用于提取输入向量。

示例：

如果指标`http_requests_total`有按 `application`、 `instance`和 `group`标签展开的时间序列，我们可以通过以下方法计算每个应用程序和组在所有实例中的HTTP请求总数：

```
sum without (instance) (http_requests_total)
```

等价于：

```
sum by (application, group) (http_requests_total)
```

如果我们只是对我们在所有应用程序的HTTP请求的总数感兴趣，我们可以简单地写：

```
sum(http_requests_total)
```

要计算运行每个构建版本的二进制文件的数量，我们可以这样写：

```
count_values("version", build_version)
```

要获取所有实例中最大的5个HTTP请求，我们可以这样写：

```
topk(5, http_requests_total)
```

### 二元运算符优先级

下面的列表显示了Prometheus中二元运算符的优先级，从最高到最低。

1. `^`
2. `*`, `/`, `%`
3. `+`, `-`
4. `==`, `!=`, `<=`, `<`, `>=`, `>`
5. `and`, `unless`
6. `or`

具有相同优先级的操作符是左结合的。例如， `2 * 3 % 2` 等价于 `(2 * 3) % 2`。然而 `^` 是右结合的，所以 `2 ^ 3 ^ 2` 等价于 `2 ^ (3 ^ 2)`。

# node_exporter

## 服务安装

1. 安装`node_exporter`服务

   ```
   shell> wget -P /root http://local-yum.ycigilink.local/Softwares/prometheus/exporter/node_exporter-1.0.0-rc.0.linux-amd64.tar.gz
   shell> tar axf /root/node_exporter-1.0.0-rc.0.linux-amd64.tar.gz -C /usr/local
   shell> ln -sv /usr/local/node_exporter-1.0.0-rc.0.linux-amd64 /usr/local/node_exporter
   ```

2. 编写`node_exporter`服务管理文件

   ```
   shell> vim /etc/systemd/system/node_exporter.service
   	[Unit]
   	Description=Prometheus node_exporter
   
   	[Service]
   	#User=nobody
   	ExecStart=/usr/local/node_exporter/node_exporter --log.level=error
   	ExecStop=/usr/bin/killall node_exporter
   	MemoryLimit=300M #限制内存使用最多300M
   	CPUQuota=100% #限制CPU使用最多一个核
    
   	[Install]
   	WantedBy=default.target
   shell> systemctl daemon-reload
   shell> systemctl start node_exporter.service && systemctl enable node_exporter.service
   ```

## node_exporter常用选项

```
--collector.cpu.info：启用metric中的cpu_info信息；
--collector.diskstats.ignored-devices="^(ram|loop|fd|(h|s|v|xv)d[a-z]|nvme\\d+n\\d+p)\\d+$"：忽略哪些正则表达式匹配上的磁盘设备；
--collector.filesystem.ignored-mount-points="^/(dev|proc|sys|var/lib/docker/.+)($|/)"：忽略正则表达式匹配上的存储挂载点；
--collector.filesystem.ignored-fs-types="^(autofs|bi...)"：忽略正则表达式匹配的文件系统类型；


```



### 使用systemd收集器

```
使用systemd收集器：
--collector.systemd.unit-whitelist=".+"：从systemd中循环正则匹配单元；
--collector.systemd：启用systemd收集器

示例：启用systemd收集器，并收集sshd.service和node_exporter.service服务的状态
    --collector.systemd --collector.systemd.unit-whitelist="(sshd|node_exporter).service"
```

![服务收集器01](/Users/luqq/Documents/02_tec-doc/prometheus/pic/服务收集器01.png)

通过这种方式可监控服务是否处于active的状态。

### 使用文件收集器

```
shell> mkdir -p /usr/local/node_exporter/textfile_collector
shell> echo "metadata{role="docker_server",datacenter="BJ"} 1" > /usr/local/node_exporter/textfile_collector/metadata.prom

shell> vim /etc/systemd/system/node_exporter.service

```





# Grafana

## 添加数据源

1. 安装并启动grafana服务。

   ```
   shell> yum -y localinstall ./grafana-6.5.2-1.x86_64.rpm
   shell> systemctl start grafana-server.service
   shell> systemctl enable grafana-server.service
   ```

   启动服务后grafana监听在3000的端口。

2. 初次登陆grafana有初始密码（admin/admin），但登陆后需要修改密码。

3. 添加数据源。

   ![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana01.png)

   ![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana02.png)

   ![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana03.png)

   添加完成后点击首页即可看到数据源的位置已被标识为删除线。

   ![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana04.png)

4. 添加首个展示页面

   ![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana05.png)

   ![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana06.png)

   ![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana07.png)

   在该页面用于输入promQL，可以把在prometheus在页面测试完成的计算公式填写在此处，回车即可在panel处进行绘图。

   Relative time：显示当前时间以前多长时间的数据；

   Time shift：显示当前时间以前多长时间至Relative time以前的数据。

5. 从grafana官网导入已做好的页面

   ![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana08.png)

   ![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana09.png)

![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana10.png)

![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana11.png)

![添加数据源](/Users/luqq/Documents/02_tec-doc/prometheus/pic/grafana12.png)

## 监控mysql

被监控端：

```
shell> wget -P /root http://local-yum.ycigilink.local/Softwares/prometheus/mysqld_exporter-0.12.1.linux-amd64.tar.gz
shell> tar axf /root/mysqld_exporter-0.12.1.linux-amd64.tar.gz.tar.gz -C /usr/local
shell> cd /usr/local
shell> ln -sv mysqld_exporter-0.12.1.linux-amd64.tar.gz mysqld_exporter
shell> vim /root/.my.cnf
		[client]
    host=localhost
    user=root
    password=ycig1234
shell> daemonize -c /usr/local/mysqld_exporter /usr/local/mysqld_exporter/mysqld_exporter
shell> ps aux | grep mysqld_exporter
shell> ss -tunlp | grep mysqld_exporter
```

监控端：

```
shell> vim /usr/local/prometheus/prometheus.yml
  - job_name: 'mysqld'
    static_configs:
    - targets: ['test0.ycigilink.local:9104']
shell> systemctl restart prometheus
```

注意：如使用“11329”的模板时需要在数据库上授权“root@::1”的用户。

推荐使用7632和11329号模板。
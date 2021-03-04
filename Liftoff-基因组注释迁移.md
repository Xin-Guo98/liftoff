#   Liftoff-基因组注释迁移

<u> 方法介绍</u>

---
### 背景

​    最近的测序技术的发展大大减少了测序和组装新基因组所需的时间和资金。目前在GenBank里有13,420个真核基因组组合，仅在过去的5年里就增加了1万个。新的和改进的基因组装的增加是对许多物种的遗传学研究的起点;但是，为了最大限度地发挥作用，基因和其他功能元件需要得到注释。然而新基因组的注释并没有跟上测序的步伐。GenBank中的13420个真核基因组只有3540个有注释。真核基因组注释是一个具有挑战性的过程，需要结合计算预测、实验验证和人工管理。相比于重复这种复杂的工作，将过去已经注释过的注释信息迁移到密切相关的物种中不失为一个灵活的方法。
​    Liftoff即是一种可以将GFF或GTF格式的注释精确映射到相同或相似物种的工具。
​    Liftoff是基于Python编写的工具包，可以直接安装使用。



### 需用软件列表

| 软件名                   | 参数                                                         | 输入                                                         | 输出                                         | 使用                                                         |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | -------------------------------------------- | ------------------------------------------------------------ |
| Liftoff                  | -g    -o                                                     | 目标基因组序列fasta文件    参考基因组序列fasta文件    参考基因组注释文件 | 迁移得到的目标基因组注释文件                 | `liftoff [target] [reference] -g [annotation.gff] -o [filename]` |
| bedtools        subtract | -a -b                                                        | 一般为基因或转录本的bed文件   外显子的bed文件                | 一般为内含子的bed文件                        | `bedtools subtract -a [A.bed] -b [B.bed] > outputfile.bed`   |
| bedtools getfasta        | -fi                          -bed         -fo                | -fi输入基因组序列fasta文件，-bed输入需要映射到基因组上的bed文件 | 输出bed文件位置对应的序列                    | `bedtools getfasta -fi genome.fa -bed intron.bed -fo intron.fa` |
| gffread                  | -x  -g                                                       | -x是提取CDS的命令，-g输入基因组序列fasta文件以及注释文件     | ORF的序列fasta文件                           | `gffread -x outputfile.fa -g genome.fa annotation.gff`       |
| blast（makeblastdb）     | -in                              -dbtype            -out     | `-in`后是输入用于建库的序列fasta文件，  `-dbtype`是建库类型，可供选择的有nucl和prot，容易理解nucl是核酸，prot是蛋白质。     `-out`是库的名字 | `database.nhr` `database.nin` `database.nsq` | `makeblastdb -in yangtuo_alpaca_gffread.fa -dbtype nucl -out yangtuo_alpaca_db` |
| blast（blastn）          | -query     -db             -out                 -evalue           -outfmt | `-query`后加待比对序列的fasta文件，`-db`后加上一步生成的库名，`-out`后加输出比对结果的文件名，  `-evalue`是设定evalue的阈值，`-outfmt`是输出文件的格式，从0-18可供选择，6为表格文件 | 表格等形式的比对结果                         | `blastn -query yangtuo_guanaco_gffread.fa -db yangtuo_alpaca_database -out yangtuo_guanacoblast.csv -evalue 1e-5 -outfmt 6` |



### 需用自定义程序列表

| 程序名                  | 输入                                     | 输出                                     | 说明                                                         |
| ----------------------- | ---------------------------------------- | ---------------------------------------- | ------------------------------------------------------------ |
| `No.1protein_coding.pl` | 注释文件`.gff`                           | 注释文件`.gff`                           | 从注释中提取出编码蛋白质的基因以及其他特征                   |
| `No.3countorfatg.pl`    | 输入文件为orf序列fasta文件               | 输出为提取的orf第一行，可以写入fasta文件 | gffread生成的orf序列每行70bases，提取第一行（最后一行）来计算以ATG开头的比例 |
| `No.4orf_atgnumber.pl`  | No.3输出的orf第一行fasta文件             | 序列结构完整性比例                       | 计算结构完整性比例                                           |
| `No.6intron_gtag.pl`    | 内含子序列fasta文件                      | 符合GT-AG法则比例                        | 计算得到的内含子序列中具有完整GT-AG的比例                    |
| `No.7blastana.pl`       | `blastn`生成的`.csv`文件或其他格式的文件 | 与输入文件格式相同                       | 用于提取ID相同的序列                                         |
| `No.8lengthdist.pl`     | `blastn`生成的`.csv`文件或其他格式的文件 | 与输入文件格式相同                       | 用于对比对长度进行运算                                       |





















### 安装

最简单的安装方法是直接使用`conda`进行安装

 ```  conda install -c bioconda liftoff```
 安装过程中或许需要很多以来的包同时安装。`proceed`选择yes即可。
一般来说`miniconda`可以满足需求。
安装`miniconda`的命令如下：

    #首先需要安装conda，我们下载minicoda，文件比较小，下载过程比较快
```wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod 777 Miniconda3-latest-Linux-x86_64.sh #给执行权限
bash Miniconda3-latest-Linux-x86_64.sh```
还需添加镜像/频道：

```
```
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
```





### 软件使用

一般来说，使用以下命令足以完成基本要求：

​    `liftoff [target] [reference] -g [annotation.gff] -o [filename]`



*`target`表示目标基因组序列的fasta格式的文件*
*`reference`表示参考基因组序列的fasta格式的文件*
`-g`后面跟着的是参考基因组的注释文件
`-o`后面跟着是输出文件的名字，输出的文件是根据参考基因组注释迁移到目标基因组的注释文件，格式是`gff3`格式。（运行时间取决于基因组大小，对于羊驼基因组2G左右大小，大约需要15-20分钟)
参考注释会自动生成数据库。

#### 其他参数

有需要再补充

### 输出文件

输入注释文件后，特征数据库会自动构建。输出是与参考基因组注释文件相同的格式，例如GFF3或GTF，以及一个带有未映射的基因ID的文件。

### 应用举例

如将人类基因组的注释迁移到黑猩猩的基因组，使用如下命令：

​    `liftoff GCA_002880755.3_Clint_PTRv2.genomic.fna GRCh38.p13.genome.fa -g gencode.v35.annotation.gff3 -o test.gff3`

其中`GCA**.fna`是黑猩猩的基因序列的fasta文件，来自NCBI数据库，`GRCh38.p13.genome.fa`是人类基因组序列fasta文件，来自Gencode数据库，目的是与同样来自Gencode数据库的注释文件`gencode.v35.annotation.gff3`相匹配。







## 结果准确性评估

通过对`liftoff`这个工具映射序列的结构完整以及序列完整性进行评估，发现此工具具有可信度。拿黑猩猩和人类基因组的迁移来说，其序列平均相似度达97%以上（开放阅读框ORF），结构完整性与参考基因组相比也可以达到98%以上（主要考虑内含子`GT-AG`法则，以及开放阅读框是否以起始密码子开头，终止密码子结尾）。

**评估过程中还需要用到的其他软件和代码**
***完整性评估***

 序列完整性主要通过序列特征进行，如ORF以起始密码子ATG开头，以终止密码子TAA、TAG、TGA结尾；以及内含子符合GT-AG法则。因为gff3格式的注释文件中并不包括内含子，所以需要用另一个工具计算得到内含子，即`bedtools`其中的`subtract`函数。
 `bedtools`安装


``` wget https://github.com/arq5x/bedtools2/archive/v2.25.0.tar.gz
tar xzvf v2.25.0 
cd bedtools2-2.25.0/
make
cd bin/
export PATH=$PWD:$PATH
```

其中的`subtract`函数使用代码如下

    bedtools subtract -a [A.bed] -b [B.bed] > outputfile.bed

内含子的坐标需要使用基因（gene）或转录本（transcript）减去外显子（exon）获得。
但是需要注意的是，gff格式的注释文件起始坐标是1，结束至少为1，例如以起始密码子的坐标为例，在gff格式的文件中，其坐标可能为（1，3），表示123，而对于bed格式的文件，起始坐标为0，结束至少为1，对于上述密码子的坐标，bed文件表示为（0，3），即不含头。需要把gff文件的起始坐标都减去1，再进行计算。


------------




## **pipeline**

1.提取各物种注释文件中的蛋白质编码基因。脚本如下`No.1protein_coding.pl`需根据不同文件进行适量修改再使用。输入为注释文件`.gff`输出文件格式一般也是`.gff`
2.使用`gffread`拼接出ORF(提取CDS拼接），其也可通过`conda`进行安装，如下

    conda install gffread -y


之后通过软连接添加到环境变量

    ln -s ~/miniconda3/bin/gffread ~/.soft
    source .bashrc


其使用命令

    gffread -x outputfile.fa -g genome.fa annotation.gff
    #-x 为提取CDS

注：`gffread`生成的fasta文件是多行表示的，即每行70bases。

3.计算ORF中是否有完整结构。可以通过提取第一行序列计算ATG出现的比例，脚本`No.3countorfatg.pl`可以提取第一行。输入文件为orf序列fasta文件，输出为提取的orf第一行。可以写入fasta文件。
`No.4orf_atgnumber.pl`可以计算结构完整性比例。

4.内含子结构完整性
如上所述先使用`bedtools`中的`subtract`函数，从蛋白质编码序列中分别用`awk`提取出正负链的gene/mRNA和exon。

    bedtools subtract -a gene.bed -b exon.bed > intron.bed
    
    awk 'BEGIN {OFS="\t"} {if($7=="+") print $1,$4,$5,$3,$6,$7;}' yangtuo_llama_protein1.gff  >yangtuo_llama+.gff
```
awk 'BEGIN {OFS="\t"} {if($4=="gene") print $1,$2,$3,$4,$5,$6;}' yangtuo_llama+.gff > yangtuo_llama+gene.bed
awk 'BEGIN {OFS="\t"} {if($4=="exon") print $1,$2,$3,$4,$5,$6;}' yangtuo_llama+.gff > yangtuo_llama+exon.bed
```



之后再使用`bedtools`中的`getfasta`函数得到内含子的序列

    bedtools getfasta -fi genome.fa -bed intron.bed -fo intron.fa
计算得到的序列中具有完整GT-AG的比例，脚本为`No.6intron_gtag.pl`

**相似性和序列长度评估**
进行相似性和长度评估需要进行序列比对。能做到序列两两依次比对的一般常用本地版blast进行局部双序列比对。

#### blast安装

1.进入NCBI官网[NCBI][1]
2.点击All Resources
3.Downloads
4.BLAST(Stand-alone)[blast][2]根据需要选择相应安装包下载

    wget ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.10.1+-x64-linux.tar.gz
    tar -zxvf ncbi-blast-2.7.1+-x64-linux.tar.gz #解压
    mv ncbi-blast-2.7.1+-x64-linux.tar.gz blast #改名
    echo export PATH="~/blast/bin/:$PATH" >>.bashrc 
    source .bashrc


设置坏境变量并将其写入`.bashrc`使其可以直接使用。



5.用参考物种的ORF序列建库。

    makeblastdb -in yangtuo_alpaca_gffread.fa -dbtype nucl -out yangtuo_alpaca_db
  `-in`后是输入需要建库的fasta文件，`-dbtype`是建库类型，可供选择的有nucl和prot，容易理解nucl是核酸，prot是蛋白质。`-out`是库的名字。

建库后生成以下文件

    yangtuo_alpaca_database.nhr
    yangtuo_alpaca_database.nin
    yangtuo_alpaca_database.nsq

6.blast有几个可执行文件，分别是`blastn`  `blastx`  `blastp`   `tblastn`   `tblastx` 等，
blastn:核苷酸与核苷酸库比对(核苷酸层面)
blastx:核苷酸与蛋白质库比对(核苷酸翻译成蛋白质，在蛋白层面进行比对)
blastp:蛋白质与蛋白质库比对
tblastn:蛋白质与核苷酸库比对(核苷酸库翻译成蛋白质再进行比对)
tblastx:核苷酸与核苷酸库比对(蛋白质层面)
很明显，在这里需要用到就是`blastn`

     blastn -query yangtuo_guanaco_gffread.fa -db yangtuo_alpaca_database -out yangtuo_guanacoblast.csv -evalue 1e-5 -outfmt 6
其中`-query`后加待比对序列的fasta文件，`-db`后加上一步生成的库名，`-out`后加输出比对结果的文件名，`-evalue`是设定evalue的阈值，`-outfmt`是输出文件的格式，从0-18可供选择，6为表格文件。生成的表格无表头，每一列代表一下内容

> query ID|    subject ID |  相似度  |  比对长度 |   错配数 |   query start |   query end |   subject start  |  subject end    |    evalue |    score

7.提取序列ID相同的进行相似度和比对长度比对结果评估
`No.7blastana.pl`用于提取ID相同的序列，输入为`blastn`生成的`.csv`文件或其他格式的文件，输出一般为相同格式的文件。
`No.8lengthdist.pl`用于对比对长度进行运算，输入同样为`blastn`生成的`.csv`文件或其他格式的文件，输出一般为相同格式的文件。

8.相似度与长度的比对结果用R中的ggplot2包进行呈现。

    data1 <- read.csv("guanaco_blast.csv",header = TRUE)
    p1 <- ggplot(data1,aes(x=相似度))
    p1+geom_histogram(binwidth=0.25,fill="#69b3a2",color="#e9ecef")+labs(title = "guanaco")
    length_data1 <- read.csv("guanaco_length.csv",header = FALSE)
    p2 <- ggplot(length_data1,aes(x=V3))
    p2+geom_histogram(binwidth=2,fill="#69b3a2",color="#e9ecef")+labs(title = "vicugna",x="length_diff")


​    
​    

[1]: https://www.ncbi.nlm.nih.gov/
[2]: ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/

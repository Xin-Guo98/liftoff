# Liftoff-基因组注释迁移工具使用及其评估

## 背景介绍

 GenBank中的13420个真核基因组只有3540个有注释。真核基因组注释是一个具有挑战性的过程，需要结合计算预测、实验验证和人工管理。相比于重复这种复杂的工作，将过去已经注释过的注释信息迁移到密切相关的物种中不失为一个灵活的方法。
    Liftoff即是一种可以将GFF或GTF格式的注释精确映射到相同或相似物种的工具。
    Liftoff是基于Python编写的工具包，可以直接安装使用。



| 软件包   | 命令        | 简介                                                         | 参考文献       |
| -------- | ----------- | ------------------------------------------------------------ | -------------- |
| Liftoff  | liftoff     | 参考基因组迁移得到目标基因组注释文件                         | [1](#参考文献) |
| bedtools | subtract    | 进行基因组坐标的减法运算，如用基因和外显子坐标相减得到内含子坐标 | [2](#参考文献) |
| bedtools | getfasta    | 将注释文件的位置信息转换为对应序列信息                       | [2](#参考文献) |
| gffread  | gffread     | 用于提取拼接CDS注释文件                                      | [3](#参考网址) |
| blast    | makeblastdb | 使用参考物种的序列构建                                       |                |
| blast    | blastn      | 核苷酸序列局部比对                                           |                |



## 软件下载和安装

| 软件/依赖包 | 版本号  | 语言   | 安装环境             | 下载地址                                                     |
| ----------- | ------- | ------ | -------------------- | ------------------------------------------------------------ |
| Liftoff     | v1.5.1  | python | Windows或Linux       | https://github.com/agshumate/Liftoff 安装命令如下            |
| bedtools    | v2.25.0 | C/C++  | Linux                | https://github.com/arq5x/bedtools2/archive/v2.25.0.tar.gz 具体安装命令见下 |
| gffread     | v0.12.1 | C/C++  | Linux或OS X          | http://ccb.jhu.edu/software/stringtie/gff.shtml#gffread 具体安装命令见下 |
| blast       | 2.7.1   | C/C++  | Linux、OS X或Windows | https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.7.1/ |
| miniconda   | 3       |        | Linux                | https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh |



```
#conda安装Liftoff
conda install -c bioconda liftoff

#bedtool安装详细命令
wget https://github.com/arq5x/bedtools2/archive/v2.25.0.tar.gz
tar xzvf v2.25.0 
cd bedtools2-2.25.0/
make
cd bin/
export PATH=$PWD:$PATH

#gffread安装详细命令
conda install gffread -y  #使用conda安装
ln -s ~/miniconda3/bin/gffread ~/.soft   #通过软连接添加到环境变量
source .bashrc

#blast安装详细命令
wget ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.7.1+-x64-linux.tar.gz
tar -zxvf ncbi-blast-2.7.1+-x64-linux.tar.gz #解压
mv ncbi-blast-2.7.1+-x64-linux.tar.gz blast #改名
echo export PATH="~/blast/bin/:$PATH" >>.bashrc 
source .bashrc

#miniconda安装详细命令
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod 777 Miniconda3-latest-Linux-x86_64.sh #给执行权限
bash Miniconda3-latest-Linux-x86_64.sh
#添加镜像/频道
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
```



## 使用说明及建议

### 输入和输出

| 命令                     | 输入 (格式)                                                  | 输出（格式）                                 |
| ------------------------ | ------------------------------------------------------------ | -------------------------------------------- |
| Liftoff                  | 目标基因组序列fasta文件    参考基因组序列fasta文件    参考基因组注释文件`.gff3` | 迁移得到的目标基因组注释文件 `.gff3`         |
| bedtools        subtract | 一般为基因或转录本的bed文件   外显子的bed文件                | 一般为内含子的bed文件                        |
| bedtools getfasta        | -fi输入基因组序列fasta文件，-bed输入需要映射到基因组上的bed文件 | 输出bed文件位置对应的序列                    |
| gffread                  | -x是提取CDS的命令，-g输入基因组序列fasta文件以及注释文件     | ORF的序列fasta文件                           |
| blast（makeblastdb）     | `-in`后是输入用于建库的序列fasta文件，  `-dbtype`是建库类型，可供选择的有nucl和prot，容易理解nucl是核酸，prot是蛋白质。     `-out`是库的名字 | `database.nhr` `database.nin` `database.nsq` |
| blast（blastn）          | `-query`后加待比对序列的fasta文件，`-db`后加上一步生成的库名，`-out`后加输出比对结果的文件名，  `-evalue`是设定evalue的阈值，`-outfmt`是输出文件的格式，从0-18可供选择，6为表格文件 | 表格等形式的比对结果                         |

### 重要单参数

#### Liftoff

| 参数     | 说明                                 | 默认值 | 推荐值（文献/网址） |
| -------- | ------------------------------------ | ------ | ------------------- |
| filename | 目标基因组序列文件名，参考序列文件名 | 无     | 无                  |
| -g       | 后加参考基因组注释文件               | 无     | 无                  |
| -o       | 输出文件                             | _      | 无                  |

#### bedtools subtract

| 参数 | 说明                                                         | 默认值 | 推荐值（文献/网址） |
| ---- | ------------------------------------------------------------ | ------ | ------------------- |
| -a   | 一种基因组特征注释的bed文件，如基因                          | 无     | 无                  |
| -b   | 另一种基因组注释的bed文件，如外显子，应为`-a`后所加bed文件坐标的子集 | 无     | 无                  |

#### bedtools  getfasta

| 参数 | 说明                            | 默认值 | 推荐值（文献/网址） |
| ---- | ------------------------------- | ------ | ------------------- |
| -fi  | 输入基因组序列fasta文件         | 无     | 无                  |
| -bed | 输入需要映射到基因组上的bed文件 | 无     | 无                  |
| -fo  | 输出bed文件位置对应的序列       | _      | 无                  |

#### gffread

| 参数 | 说明                                | 默认值 | 推荐值（文献/网址） |
| ---- | ----------------------------------- | ------ | ------------------- |
| -x   | 提取CDS的命令,后加输出的fasta文件   | 无     | 无                  |
| -g   | 输入基因组序列fasta文件以及注释文件 | 无     | 无                  |

#### blast makeblastdb

| 参数    | 说明                                        | 默认值 | 推荐值（文献/网址） |
| ------- | ------------------------------------------- | ------ | ------------------- |
| -in     | `-in`后是输入用于建库的序列fasta文件        | 无     | 无                  |
| -dbtype | `-dbtype`是建库类型，可供选择的有nucl和prot | nucl   | 无                  |
| -out    | 库的名字                                    | _      | 无                  |

#### blast blastn

| 参数    | 说明                                                   | 默认值 | 推荐值（文献/网址） |
| ------- | ------------------------------------------------------ | ------ | ------------------- |
| -query  | `-query`后加待比对序列的fasta文件                      | 无     | 无                  |
| -db     | `-db`后加建库生成的库名                                |        | 无                  |
| -out    | `-out`后加输出比对结果的文件名                         | _      | 无                  |
| -evalue | `-evalue`是设定evalue的阈值                            | 无     | 无                  |
| -outfmt | `-outfmt`是输出文件的格式，从0-18可供选择，6为表格文件 | 6      | 6                   |

### 参数组合

暂无

## 辅助脚本

### 脚本清单

| 作者    | 脚本                                                         | 语言 | 目的                                                         | 输入 （格式）                            | 输出（格式）                       |
| ------- | ------------------------------------------------------------ | ---- | ------------------------------------------------------------ | ---------------------------------------- | ---------------------------------- |
| Xin-Guo | [`protein_coding.pl`](https://github.com/Xin-Guo98/liftoff/blob/main/Scripts/protein_coding.pl) | perl | 从注释中提取出编码蛋白质的基因以及其他特征                   | 注释文件`.gff`                           | 注释文件`.gff`                     |
| Xin-Guo | [`countorfatg.pl`](https://github.com/Xin-Guo98/liftoff/blob/main/Scripts/countorfatg.pl) | perl | gffread生成的orf序列每行70bases，提取第一行（最后一行）来计算以ATG开头的比例 | 输入文件为orf序列fasta文件               | 提取的orf第一行，可以写入fasta文件 |
| Xin-Guo | [`orf_atgnumber.pl`](https://github.com/Xin-Guo98/liftoff/blob/main/Scripts/orf_atgnumber.pl) | perl | 计算结构完整性比例                                           | `countorfatg.pl`输出的orf第一行fasta文件 | 序列结构完整性比例                 |
| Xin-Guo | [`intron_gtag.pl`](https://github.com/Xin-Guo98/liftoff/blob/main/Scripts/intron_gtag.pl) | perl | 计算得到的内含子序列中具有完整GT-AG的比例                    | 内含子序列fasta文件                      | 符合GT-AG法则比例                  |
| Xin-Guo | [`blastana.pl`](https://github.com/Xin-Guo98/liftoff/blob/main/Scripts/blastana.pl) | perl | 用于提取ID相同的序列                                         | `blastn`生成的`.csv`文件或其他格式的文件 | 与输入文件格式相同                 |
| Xin-Guo | [`lengthdist.pl`](https://github.com/Xin-Guo98/liftoff/blob/main/Scripts/lengthdist.pl) | perl | 用于对比对长度进行运算                                       | `blastn`生成的`.csv`文件或其他格式的文件 | 与输入文件格式相同                 |

### 脚本参数

无

## 实例

### 使用`Liftoff`迁移基因组注释

一般来说，使用以下命令足以完成基本要求：

```
  liftoff [target] [reference] -g [annotation.gff] -o [filename]
```

*`target`表示目标基因组序列的fasta格式的文件*
*`reference`表示参考基因组序列的fasta格式的文件*
`-g`后面跟着的是参考基因组的注释文件
`-o`后面跟着是输出文件的名字，输出的文件是根据参考基因组注释迁移到目标基因组的注释文件，格式是`gff3`格式。（运行时间取决于基因组大小，对于羊驼基因组2G左右大小，大约需要15-20分钟)
参考注释会自动生成数据库。

如将人类基因组的注释迁移到黑猩猩的基因组，使用如下命令：

```
liftoff GCA_002880755.3_Clint_PTRv2.genomic.fna GRCh38.p13.genome.fa -g gencode.v35.annotation.gff3 -o test.gff3
```

其中`GCA**.fna`是黑猩猩的基因序列的fasta文件，来自NCBI数据库，`GRCh38.p13.genome.fa`是人类基因组序列fasta文件，来自Gencode数据库，目的是与同样来自Gencode数据库的注释文件`gencode.v35.annotation.gff3`相匹配。

### 对`Liftoff`结果准确性评估

通过对`liftoff`这个工具映射序列的结构完整以及序列完整性进行评估，发现此工具具有可信度。拿黑猩猩和人类基因组的迁移来说，其序列平均相似度达97%以上（开放阅读框ORF），结构完整性与参考基因组相比也可以达到98%以上（主要考虑内含子`GT-AG`法则，以及开放阅读框是否以起始密码子开头，终止密码子结尾）。

评估过程中还需要用到的其他软件和代码。

 序列完整性主要通过蛋白质编码序列特征进行，如ORF以起始密码子ATG开头，以终止密码子TAA、TAG、TGA结尾；以及内含子符合GT-AG法则。

首先需要提取各物种注释文件中的蛋白质编码基因。脚本如下`protein_coding.pl`。输入为注释文件`.gff`输出文件格式一般也是`.gff`

 **（1）起始/终止密码子完整性评估**

使用`gffread`拼接出ORF(提取CDS拼接）

其使用命令

    gffread -x outputfile.fa -g genome.fa annotation.gff
    #-x 为提取CDS

注：`gffread`生成的fasta文件是多行表示的，即每行70bases。

 计算ORF中是否有完整起始/终止密码子结构。可以通过提取第一行序列计算ATG出现的比例，脚本`countorfatg.pl`可以提取第一行。输入文件为orf序列fasta文件，输出为提取的orf第一行。可以写入fasta文件。
`orf_atgnumber.pl`可以计算完整起始/终止密码子比例。

**（2）内含子完整性评估**

因为gff3格式的注释文件中并不包括内含子，所以需要用另一个工具计算得到内含子，即`bedtools`其中的`subtract`函数。

内含子的坐标需要使用基因（gene）或转录本（transcript）减去外显子（exon）获得。

首先从蛋白质编码序列中分别用`awk`提取出正负链的gene/mRNA和exon。



    awk 'BEGIN {OFS="\t"} {if($7=="+") print $1,$4,$5,$3,$6,$7;}' llama_protein1.gff  >llama+.gff
    awk 'BEGIN {OFS="\t"} {if($4=="gene") print $1,$2,$3,$4,$5,$6;}' llama+.gff > llama+gene.bed
    awk 'BEGIN {OFS="\t"} {if($4=="exon") print $1,$2,$3,$4,$5,$6;}' llama+.gff > llama+exon.bed

其中的`subtract`函数使用代码如下



    bedtools subtract -a llama+gene.bed -b llama+exon.bed > llama_intron.bed


但是需要注意的是，gff格式的注释文件起始坐标是1，结束至少为1，例如以起始密码子的坐标为例，在gff格式的文件中，其坐标可能为（1，3），表示123，而对于bed格式的文件，起始坐标为0，结束至少为1，对于上述密码子的坐标，bed文件表示为（0，3），即不含头。需要把gff文件的起始坐标都减去1，再进行计算。

之后再使用`bedtools`中的`getfasta`函数得到内含子的序列

    bedtools getfasta -fi genome.fa -bed intron.bed -fo intron.fa

计算得到的序列中具有完整GT-AG的比例，脚本为`intron_gtag.pl`

**(3) 相似性和长度评估**

进行相似性和长度评估需要进行序列比对。能做到序列两两依次比对的一般常用本地版blast进行局部双序列比对。



用参考物种的ORF序列建库。

    makeblastdb -in alpaca_gffread.fa -dbtype nucl -out alpaca_db

  `-in`后是输入需要建库的fasta文件，`-dbtype`是建库类型，可供选择的有nucl和prot，容易理解nucl是核酸，prot是蛋白质。`-out`是库的名字。

建库后生成以下文件



```
alpaca_database.nhr
alpaca_database.nin
alpaca_database.nsq
```

blast有几个可执行文件，分别是`blastn`  `blastx`  `blastp`   `tblastn`   `tblastx` 等，
blastn:核苷酸与核苷酸库比对(核苷酸层面)
blastx:核苷酸与蛋白质库比对(核苷酸翻译成蛋白质，在蛋白层面进行比对)
blastp:蛋白质与蛋白质库比对
tblastn:蛋白质与核苷酸库比对(核苷酸库翻译成蛋白质再进行比对)
tblastx:核苷酸与核苷酸库比对(蛋白质层面)
很明显，在这里需要用到就是`blastn`

```
 blastn -query yangtuo_guanaco_gffread.fa -db yangtuo_alpaca_database -out yangtuo_guanacoblast.csv -evalue 1e-5 -outfmt 6
```

其中`-query`后加待比对序列的fasta文件，`-db`后加上一步生成的库名，`-out`后加输出比对结果的文件名，`-evalue`是设定evalue的阈值，`-outfmt`是输出文件的格式，从0-18可供选择，6为表格文件。生成的表格无表头，每一列代表一下内容

- query ID|    subject ID |  相似度  |  比对长度 |   错配数 |   query start |   query end |   subject start  |  subject end    |    evalue |    score

提取序列ID相同的进行相似度和比对长度比对结果评估
`blastana.pl`用于提取ID相同的序列，输入为`blastn`生成的`.csv`文件或其他格式的文件，输出一般为相同格式的文件。
`lengthdist.pl`用于对比对长度进行运算，输入同样为`blastn`生成的`.csv`文件或其他格式的文件，输出一般为相同格式的文件。



相似度与长度的比对结果用**R**中的ggplot2包进行呈现。

```
data1 <- read.csv("guanaco_blast.csv",header = TRUE)
p1 <- ggplot(data1,aes(x=相似度))
p1+geom_histogram(binwidth=0.25,fill="#69b3a2",color="#e9ecef")+labs(title = "guanaco")
length_data1 <- read.csv("guanaco_length.csv",header = FALSE)
p2 <- ggplot(length_data1,aes(x=V3))
p2+geom_histogram(binwidth=2,fill="#69b3a2",color="#e9ecef")+labs(title = "vicugna",x="length_diff")
```



## 参考文献

1. Liftoff: an accurate gene annotation mapping tool[J]. Journal of Engineering,2020.

2. Quinlan Aaron R. BEDTools: The Swiss-Army Tool for Genome Feature Analysis.[J]. Current protocols in bioinformatics, 2014, 47 : 11.12.1-34.

3. https://gist.github.com/darencard/9497e151882c3ff366335040e20b6714

   

   

   

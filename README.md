# liftoff
#The use of liftoff and assess its outputs
# Liftoff-基因组注释迁移

标签（空格分隔）： 方法介绍

---
###背景
    最近的测序技术的发展大大减少了测序和组装新基因组所需的时间和资金。目前在GenBank里有13,420个真核基因组组合，仅在过去的5年里就增加了1万个。新的和改进的基因组装的增加是对许多物种的遗传学研究的起点;但是，为了最大限度地发挥作用，基因和其他功能元件需要得到注释。然而新基因组的注释并没有跟上测序的步伐。GenBank中的13420个真核基因组只有3540个有注释。真核基因组注释是一个具有挑战性的过程，需要结合计算预测、实验验证和人工管理。相比于重复这种复杂的工作，将过去已经注释过的注释信息迁移到密切相关的物种中不失为一个灵活的方法。
    Liftoff即是一种可以将GFF或GTF格式的注释精确映射到相同或相似物种的工具。
    Liftoff是基于Python编写的工具包，可以直接安装使用。
###安装
最简单的安装方法是直接使用conda进行安装

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
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
```

###软件使用
一般来说，使用以下命令足以完成基本要求：

    liftoff [target] [reference] -g [annotation.gff] -o [filename]



*`target`表示目标基因组序列的fasta格式的文件*
*`reference`表示参考基因组序列的fasta格式的文件*
`-g`后面跟着的是参考基因组的注释文件
`-o`后面跟着是输出文件的名字，输出的文件是根据参考基因组注释迁移到目标基因组的注释文件，格式是`gff3`格式。（运行时间取决于基因组大小，对于羊驼基因组2G左右大小，大约需要15-20分钟)
参考注释会自动生成数据库。

####其他参数
有需要再补充


###输出文件
输入注释文件后，特征数据库会自动构建。输出是与参考基因组注释文件相同的格式，例如GFF3或GTF，以及一个带有未映射的基因ID的文件。

###应用举例
如将人类基因组的注释迁移到黑猩猩的基因组，使用如下命令：

    liftoff GCA_002880755.3_Clint_PTRv2.genomic.fna GRCh38.p13.genome.fa -g gencode.v35.annotation.gff3 -o test.gff3

其中`GCA**.fna`是黑猩猩的基因序列的fasta文件，来自NCBI数据库，`GRCh38.p13.genome.fa`是人类基因组序列fasta文件，来自Gencode数据库，目的是与同样来自Gencode数据库的注释文件`gencode.v35.annotation.gff3`相匹配。

###结果准确性评估
通过对`liftoff`这个工具映射序列的结构完整以及序列完整性进行评估，发现此工具具有可信度。拿黑猩猩和人类基因组的迁移来说，其序列平均相似度达97%以上（开放阅读框ORF），结构完整性与参考基因组相比也可以达到98%以上（主要考虑内含子`GT-AG`法则，以及开放阅读框是否以起始密码子开头，终止密码子结尾）。

###评估过程中还需要用到的其他软件和代码
**完整性评估**

 一. 评估完整性
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
**pipeline**
1.提取各物种注释文件中的蛋白质编码基因。脚本如下`No.1protein_coding.pl`需根据不同文件进行适量修改再使用。
2.使用`gffread`拼接出ORF(提取CDS拼接），其也可通过`conda`进行安装，如下

    conda install gffread -y


之后通过软连接添加到环境变量

    ln -s ~/miniconda3/bin/gffread ~/.soft
    source .bashrc
    
    
其使用命令

    gffread -x outputfile.fa -g genome.fa annotation.gff
    #-x 为提取CDS
    
注：`gffread`生成的fasta文件是多行表示的，即每行70bases。
3.计算ORF中是否有完整结构。可以通过提取第一行序列计算ATG出现的比例，脚本`No.3countorfatg.pl`可以提取第一行。`No.4orf_atgnumber.pl`可以计算结构完整性比例。
4.内含子结构完整性
如上所述先使用`bedtools`中的`subtract`函数，从蛋白质编码序列中分别用`awk`提取出正负链的gene/mRNA和exon。

    bedtools subtract -a gene.bed -b exon.bed > intron.bed

    awk 'BEGIN {OFS="\t"} {if($7=="+") print $1,$4,$5,$3,$6,$7;}' yangtuo_llama_protein1.gff  >yangtuo_llama+.gff
awk 'BEGIN {OFS="\t"} {if($4=="gene") print $1,$2,$3,$4,$5,$6;}' yangtuo_llama+.gff > yangtuo_llama+gene.bed
awk 'BEGIN {OFS="\t"} {if($4=="exon") print $1,$2,$3,$4,$5,$6;}' yangtuo_llama+.gff > yangtuo_llama+exon.bed



之后再使用`bedtools`中的`getfasta`函数得到内含子的序列

    bedtools getfasta -fi genome.fa -bed intron.bed -fo intron.fa
计算得到的序列中具有完整GT-AG的比例，脚本为`No.5intron_gtag.pl`


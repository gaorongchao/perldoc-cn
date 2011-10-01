#!perl

use strict;
use warnings;
use 5.010;
use autodie;
use File::Basename qw<basename>;
use Regexp::Common qw<URI>;

# -----------------------
# 预处理Pod中的内容
# -----------------------

# 调试模式，设置输出句柄
my $DEBUG = 1;
if ($DEBUG) {
   open(DEBUG, '>', 'debug.pod');
}

# 显式定义空格和制表符
my $blank = "\x{0020}";
my $tab = $blank x 4;

# 以流格式打开所有POD文件进行预处理
my @filelist = glob("../en/*.pod");
mkdir "../precess" unless (-e "../pod");
foreach my $podfile (@filelist) {
    my $filename = basename $podfile;
    my $outfile  = "../pod/$filename";
    say "Format $podfile ......to $outfile";
	open(my $fh_in,  '<', $podfile);
    # 输出句柄以 utf8 为编码
    open(my $fh_out, '>', $outfile);

    my $text = "";
    while (my $line = <$fh_in>) {
        chomp $line;

        # 预处理部分
        $line =~ s/\s+$//;      # 去除尾部空格
        $line =~ s/(=\w+)\s+/$1$blank/; # 标记语言后保留一个空格

        # 提取标题后的单词
        say DEBUG $1 if ($line =~ /(\w+\(\w*\))/); # 测试正则匹配

        # 如果代码为空行，则输出空行后重置$text
        if ($line =~ /^$/) {
            say {$fh_out} "$text\n";
            $text = "";
            next;
        }
        # 如果代码不以空格开始进行替换
        if ($line =~ /\S/) {
            $line =~ s/\t/$tab/g;     # 将所有制表符替换成四个空格
            $line =~ s/\s*,\s*/,$blank/g;  # 逗号后留空格
        }
        # 如果以代码格式开始，原样输出非空行
        if ($line =~ /^\s/) {
            say {$fh_out} $text;
            $text = "";
        }
        # 行内容保存起来
        $text .= "$line ";
    }
}

close DEBUG;

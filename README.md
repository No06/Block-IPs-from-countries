# Linux VPS一键允许指定的国家或IP段所有的IP访问
本脚本适用于`CentOS`、`Debian`、`Ubuntu`等常用系统。

使用`root`运行以下命令：

    wget https://raw.githubusercontent.com/No06/Block-IPs-from-countries/master/block-ips.sh
    chmod +x block-ips.sh
    ./block-ips.sh

默认只允许 `CN` 地区IP段，另需要自行修改脚本中的 `countries` 和 `iplist` 列表

  [1]: http://www.ipdeny.com/ipblocks

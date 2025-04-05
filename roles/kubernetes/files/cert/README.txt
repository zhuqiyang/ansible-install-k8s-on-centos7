这个目录中的脚本一般不需要手动执行，执行 ansible-playbook -vv install_cert.yml 命令即可生成证书。
1、ssl_vars.sh 文件中的变量用于生成域名证书，如需修改 ssl_vars.sh 则需修改 templates/ssl_vars.sh.j2
2、脚本执行顺序00、01、02。

这个目录中的目录都可以删除。

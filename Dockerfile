FROM ubuntu AS builder


# 版本
ENV VERSION 8.5.16


WORKDIR /opt/atlassian


RUN apt update -y
RUN apt install axel -y

# 下载Jira安装包
RUN axel --num-connections 64 --insecure --output jira${VERSION}.tar.gz "https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-${VERSION}.tar.gz"
RUN tar -xzf jira${VERSION}.tar.gz
RUN mv atlassian-jira-software-${VERSION}-standalone jira

# 删除不需要的文件
RUN rm -rf jira/bin/*.bat





# 打包真正的镜像
FROM storezhang/atlassian

MAINTAINER storezhang "storezhang@gmail.com"
LABEL architecture="AMD64/x86_64" version="latest" build="2021-10-22"
LABEL Description="Atlassian公司产品Jira，一个非常好的敏捷开发系统。在原来的基础上增加了MySQL/MariaDB驱动以及破解解程序"



# 开放端口
# Jira本身的端口
EXPOSE 8080



# 复制文件
COPY --from=builder /opt/atlassian/jira /opt/atlassian/jira
COPY docker /



RUN set -ex \
    \
    \
    \
    # 安装cronolog，转接catalina.out日志到Jira主目录
    && apt update -y \
    && apt upgrade -y \
    && apt install cronolog -y \
    \
    \
    \
    # 安装Jira并增加执行权限
    && chmod +x /etc/s6/jira/* \
    \
    \
    \
    # 安装MySQL/MariaDB驱动
    && cp -r /opt/oracle/mysql/lib/ /opt/atlassian/jira/ \
    \
    \
    \
    # 清理镜像，减少无用包
    && rm -rf /var/lib/apt/lists/* \
    && apt autoclean



# 设置Jira主目录
ENV JIRA_HOME /config
ENV CATALINA_TMPDIR ${JIRA_HOME}/tmp
ENV CATALINA_OUT ${JIRA_HOME}/log/catalina.out
ENV CATALINA_OUT_CMD "cronolog ${JIRA_HOME}/log/catalina.%Y-%m-%d.out"
ENV CATALINA_OPTS ""

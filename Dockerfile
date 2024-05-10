FROM haxqer/jira:9.14.1 AS jira

# 删除不需要的文件
RUN rm -rf jira/bin/*.bat


FROM ccr.ccs.tencentyun.com/storezhang/ubuntu:23.04.17 AS builder

# 复制所需要的文件
COPY --from=jira /opt/jira /docker/opt/atlassian/jira
# ! 必须在最后一步复制需要做出修改的文件，不然文件内容会被覆盖
COPY docker /docker



# 打包真正的镜像
FROM ccr.ccs.tencentyun.com/storezhang/atlassian:0.0.21


LABEL author="storezhang<华寅>" \
    email="storezhang@gmail.com" \
    qq="160290688" \
    wechat="storezhang" \
    description="Atlassian公司产品Jira，一个非常好的敏捷开发系统。在原来的基础上增加了MySQL/MariaDB驱动以及破解解程序"


# 开放端口
EXPOSE 8080


# 复制文件
COPY --from=builder /docker /


RUN set -ex \
    \
    \
    \
    # 修改主目录 \
    && echo "jira.home = ${ATLASSIAN_HOME}" > /opt/atlassian/jira/atlassian-jira/WEB-INF/classes/jira-application.properties \
    # 修复权限
    && chown -R ${USERNAME}:${USERNAME} /opt/atlassian/jira/conf \
    # 安装Jira并增加执行权限
    && chmod +x /etc/s6/jira/* \
    \
    \
    \
    # 清理镜像，减少无用包
    && rm -rf /var/lib/apt/lists/* \
    && apt autoclean


# 设置运行时变量
ENV JIRA_HOME ${ATLASSIAN_HOME}

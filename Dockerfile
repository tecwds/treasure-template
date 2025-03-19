# TODO 添加 env 支持

# maven 3.9 + openjdk-21
FROM maven:3.9-eclipse-temurin-21-jammy as builder

# 环境变量，用于设置代理

ARG PROXY_HOST=${PROXY_HOST}
ARG PROXY_PORT=${PROXY_PORT}
ARG NO_PROXY=${NO_PROXY:localhost,127.0.0.1}

#ARG MAVEN_OPTS='-Dhttp.proxyHost=172.18.160.1 -Dhttp.proxyPort=7897 -Dhttp.nonLocalHosts=localhost,127.0.0.1,172.18.0.0/20'

# 设置工作目录
WORKDIR /source

COPY pom.xml pom.xml

# 缓存依赖
RUN mvn dependency:go-offline \
    -Dhttp.proxyHost=$PROXY_HOST \
    -Dhttp.proxyPort=$PROXY_PORT \
    -Dhttp.nonLocalHosts=$NO_PROXY

# 复制源代码
COPY src .

# 打包构建

# 跳过 JUnit 测试
ARG MAVEN_OPTS="-DskipTests"

# 构建项目
RUN mvn clean package $MAVEN_OPTS

# 解压 Jar 文件
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

# 运行
FROM openjdk:21-jdk-alpine as runner

RUN addgroup -S spring && adduser -S spring -G spring

USER spring:spring

WORKDIR /app

# 使用 openjdk-21 作为运行时
ARG DEPENDENCY=/source/target/dependency
COPY --from=builder ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=builder ${DEPENDENCY}/META-INF/lib /app/META-INF
COPY --from=builder ${DEPENDENCY}/BOOT-INF/classes /app

ENTRYPOINT ["java", "cp", "app:app/lib/*", "${MAIL_CLASS_PATH}"]
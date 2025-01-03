# TODO 添加 env 支持

# maven 3.9 + openjdk-21
FROM maven:3.9-eclipse-temurin-21-jammy as builder

# 中：设置工作目录
# en: set working directory
WORKDIR /source

COPY src/pom.xml .

# 中：缓存依赖
# en: cache dependencies
RUN mvn dependency:go-offline

# 中：复制源代码
# en: copy source code
COPY src .

# 中：打包构建
# en: build project

# 跳过 JUnit 测试
# en: skip JUnit tests
ARG MAVEN_OPTS="-DskipTests"

# 中：构建项目
# en: build project
RUN mvn clean package $MAVEN_OPTS

FROM openjdk:21-jdk

WORKDIR /app

# 中：使用 openjdk-21 作为运行时
# en: use openjdk-21 as runtime
COPY --from=builder /source/target/*.jar /app/app.jar

EXPOSE 39150

ENTRYPOINT ["bash entrypoint.sh"]
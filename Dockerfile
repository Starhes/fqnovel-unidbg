# 使用 Java 8 (Ubuntu) 作为基础镜像，解决 SSL 握手失败问题
FROM eclipse-temurin:8-jdk

# 设置工作目录
WORKDIR /app

# 安装 Maven
RUN apt-get update && apt-get install -y maven

# 复制 pom.xml
COPY pom.xml .

# 复制源代码
COPY src src

# 使用 Maven 构建项目，跳过测试
# 注意：第一次构建会下载依赖，可能需要一些时间
RUN mvn package -DskipTests

# 暴露端口 9999
EXPOSE 9999

# 运行 jar 包
CMD ["java", "-jar", "target/unidbg-boot-server-0.0.1-SNAPSHOT.jar"]

# 使用 Java 8 Alpine 作为基础镜像
FROM openjdk:8-jdk-alpine

# 设置工作目录
WORKDIR /app

# 复制 Maven 包装器和 pom.xml
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# 给 mvnw 添加执行权限
RUN chmod +x mvnw

# 复制源代码
COPY src src

# 使用 Maven 构建项目，跳过测试
# 注意：第一次构建会下载依赖，可能需要一些时间
RUN ./mvnw package -DskipTests

# 暴露端口 9999
EXPOSE 9999

# 运行 jar 包
# 假设构建出的 jar 包在 target 目录下，名称可能包含版本号，这里使用通配符或者明确指定
# 根据 pom.xml，artifactId 是 unidbg-boot-server，version 是 0.0.1-SNAPSHOT
CMD ["java", "-jar", "target/unidbg-boot-server-0.0.1-SNAPSHOT.jar"]

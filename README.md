# fqnovel-unidbg
使用unidbg模拟so库执行，调用fqnovel安卓端接口

### 项目简述
- 本项目是在 [anjia0532/unidbg-boot-server](https://github.com/anjia0532/unidbg-boot-server) 基础上修改而来，主要是为了模拟fqnovel的安卓端so库执行，对fqnovel的接口进行签名并调用。 


- 说明：本项目unidbg模拟调用和加解密部分为人工完成，其余大部分代码为 `GitHub Copilot Agents` 生成，难免存在一些不合理的地方，欢迎二次开发

  - 加解密算法思路参考了 [rudo-rs/fqnovel-api](https://github.com/rudo-rs/fqnovel-api) ，非常感谢大佬分享的思路和代码示例  


- 目前已实现书籍搜索、信息获取、章节下载等核心功能，详细接口请参考 [API 接口说明](#api-接口说明)


- 需要更多接口的可以自行抓包并编写

### 部分文件及目录说明

- `tools/batch_device_register_xml.py` --- 批量生成设备注册信息的脚本
- `src/main/java/com/anjia/unidbg/IdleFQ.java` --- fqnovel-unidbg 模拟执行相关代码
- `src/test/java/com/anjia/unidbgserver/service/FQEncryptServiceTest.java` --- fqnovel-unidbg 签名加密相关测试代码
- `src/main/resources/com/dragon/read/oversea/gp` --- 存放 fqnovel-unidbg 模拟执行所需的文件
- `src/main/resources/legado/fqnovel.json` --- 纯新手 手搓的阅读3书源(Legado)的配置文件 



### 使用说明

**可参考 [anjia0532/unidbg-boot-server](https://github.com/anjia0532/unidbg-boot-server) 项目**

下面对新增的配置进行说明
- `application.yml`中新增了`fq`配置项

  - `fq`示例配置 --- 模拟的设备信息————可使用`batch_device_register_xml.py`生成
  ```yml
    fq:
      api:
          base-url: https://api5-normal-sinfonlineb.fqnovel.com
          user-agent: com.dragon.read.oversea.gp/68132 (Linux; U; Android 10; zh_CN; OnePlus11; Build/V291IR;tt-ok/3.12.13.4-tiktok)
          cookie: store-region=cn-zj; store-region-src=did; install_id=933935730456617
          device:
            aid: '1967'
            cdid: 17f05006-423a-4172-be4b-7d26a42f2f4a
            device-brand: OnePlus
            device-id: '933935730452521'
            device-type: OnePlus11
            dpi: '640'
            host-abi: arm64-v8a
            install-id: '933935730456617'
            resolution: 3200*1440
            rom-version: V291IR+release-keys
            update-version-code: '68132'
            version-code: '68132'
            version-name: 6.8.1.32
    ```


### 注意事项

- 请不要频繁调用 `获取单个章节列表 --- /api/fqnovel/chapter/{bookId}/{chapterId}` 接口，容易出现 `ILLEGAL_ACCESS`(设备信息风控) 错误，建议使用 `批量获取章节内容 --- /api/fqnovel/chapter/batch` 接口来获取章节内容

  - 同理 在使用本项目提供的书源配置时，**注意不要缓存书籍章节**，避免频繁调用接口，导致设备信息风控

### 免责声明

- 本项目仅供学习交流使用，使用时请遵守相关法律法规。用户需自行承担由此引发的任何法律责任和风险。程序的作者及项目贡献者不对因使用本程序所造成的任何损失、损害或法律后果负责！

### 感谢
- [zhkl0228/unidbg](https://github.com/zhkl0228/unidbg)
- [anjia0532/unidbg-boot-server](https://github.com/anjia0532/unidbg-boot-server)
- [rudo-rs/fqnovel-api](https://github.com/rudo-rs/fqnovel-api)

### API 接口说明

#### 1. FQNovel 核心接口 (`/api/fqnovel`)
- **获取书籍信息**: `GET /api/fqnovel/book/{bookId}`
- **获取章节内容 (GET)**: `GET /api/fqnovel/chapter/{bookId}/{chapterId}`
- **获取章节内容 (POST)**: `POST /api/fqnovel/chapter` (Body: `{"bookId": "...", "chapterId": "..."}`)
- **批量获取章节内容**: `POST /api/fqnovel/chapters/batch` (Body: `{"bookId": "...", "chapterRange": "1-10"}`)

#### 2. 书籍搜索与目录 (`/api/fqsearch`)
- **搜索书籍**: `GET /api/fqsearch/books?query=...`
- **快速搜索**: `GET /api/fqsearch/quick?query=...`
- **获取书籍目录**: `GET /api/fqsearch/directory/{bookId}`
- **简易章节列表**: `GET /api/fqsearch/chapters/{bookId}`

#### 3. 全本下载 (`/api/fullbook`)
- **全本下载 (流式)**: `POST /api/fullbook/download`
- **获取下载进度**: `GET /api/fullbook/progress/{bookId}`
- **获取已下载章节**: `GET /api/fullbook/chapters/{bookId}`
- **自动恢复下载**: `POST /api/fullbook/auto-resume/{bookId}`

#### 4. 设备管理 (`/api/device`)
- **注册设备**: `POST /api/device/register`
- **重启服务**: `POST /api/device/restart`
- **获取当前配置**: `GET /api/device/current-config`

#### 5. 签名服务 (`/api/fq-signature`)
- **生成签名**: `POST /api/fq-signature/generateSignature` (Body: `{"url": "...", "headers": "..."}`)

#### 6. 缓存管理 (`/api/cache`)
- **查询Keys**: `GET /api/cache/keys?pattern=...`
- **获取Value**: `GET /api/cache/value?key=...`

---

### Docker 部署说明

#### 构建镜像
可以简单地通过 Dockerfile 构建镜像：

```bash
docker build -t fqnovel-unidbg .
```

#### 运行容器
容器默认暴露 **9999** 端口。

```bash
docker run -d -p 9999:9999 --name fqnovel-unidbg fqnovel-unidbg
```

#### 挂载配置 (可选)
如果需要自定义 `application.yml` 或其他配置文件，可以将其挂载到容器中：

```bash
docker run -d -p 9999:9999 \
  -v /path/to/your/application.yml:/app/config/application.yml \
  --name fqnovel-unidbg fqnovel-unidbg
```


# Gemini



## Getting started
1. clone 仓库
2. 在 themes目录下执行 git clone https://github.com/zhaohuabing/hugo-theme-cleanwhite.git
3. npm 安装以来
4. ./build_algolia_index.sh 上传搜索数据到Algolia

## CI/CD流程
1. 将hugo-theme-cleanwhite 主题作为子以来仓库拉取 `git clone https://github.com/zhaohuabing/hugo-theme-cleanwhite.git themes/hugo-theme-cleanwhite --depth=1`
2. 仓库本身已经做好了algolia的node编译配置，而主题本身又支持直接algolia导出索引，所以这一步只需要执行`docker run --rm -it -v $(pwd):/src klakegg/hugo`即可
3. 需要在仓库目录下配置algolia的环境变量，是为了要将上一步生成的索引文件上传到algolia的服务，这一步准备要在docker中完成。
```shell
docker run -it  \
-e NPM_CONFIG_LOGLEVEL=info \
-e ALGOLIA_APP_ID=your_app_id \
-e ALGOLIA_ADMIN_KEY=yourkey \
-e ALGOLIA_INDEX_NAME=your_index_name \
-e ALGOLIA_INDEX_FILE=./public/algolia.json \
-v $(pwd):/gemini \
node  sh -c 'cd gemini&&npm install && npm run algolia'
```
4. 上一步完成了索引上传，这一步需要打包镜像 `docker build -t {your_tag} .`
5. 将镜像上传到自己的镜像仓库仓库，需要docker login 操作
6. 上传成功后执行 docker run 命令，挂在data目录到本地，避免每次都申请证书

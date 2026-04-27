  # 个人博客 - Hugo PaperMod

  基于 [Hugo](https://gohugo.io/) 构建的个人博客，使用 [PaperMod](https://github.com/adityatelange/hugo-PaperMod) 主题。

  ## 主题管理

  ```bash
  # 首次拉取主题（作为 git submodule）
  git submodule add https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod

  # 更新主题到最新版本
  git submodule update --remote themes/PaperMod

  ## 本地运行

  hugo server -D

  访问 http://localhost:1313 预览。

  ## 添加文章

  hugo new content/posts/文章名.md

  文章头部使用 TOML 格式：

  ---
  title: "文章标题"
  date: 2026-04-27
  draft: false
  tags: ["标签1", "标签2"]
  ---

  ## 构建

  hugo -D

  生成的静态文件位于 public/ 目录。

  ## 部署

  将 public/ 目录内容推送到 GitHub Pages、Vercel、Netlify 或自己的服务器。

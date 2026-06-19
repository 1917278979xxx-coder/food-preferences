# 🍽️ 美食偏好管理

一个帮你记住朋友口味与禁忌的轻量级 Web 应用。支持多朋友管理、实时云同步、数据导出。

## ✨ 功能

- 👥 **多朋友管理** — 添加多位朋友，分别记录每个人的饮食偏好
- ❤️👎⚠️ **三大分类** — 爱吃 / 不喜欢吃 / 过敏，一目了然
- ☁️ **云同步** — 基于 Supabase，多端数据实时同步
- 🔐 **账号登录** — 邮箱注册登录，数据安全不丢失
- 📊 **数据导出** — 支持导出 CSV（Excel）/ 文本 / PDF
- 📱 **响应式设计** — 手机、平板、电脑都能用

## 🚀 快速开始

访问线上地址：**[food-preferences.pages.dev](https://1917278979xxx-coder.github.io/food-preferences/)**

1. 注册账号（首次使用点「创建账号」）
2. 添加朋友
3. 点击朋友卡片，开始记录
4. 随时导出分享

## 🛠️ 技术栈

| 层面 | 技术 |
|------|------|
| 前端 | Vanilla HTML/CSS/JS（单文件应用） |
| 后端 | Supabase（PostgreSQL + Auth + Realtime） |
| 部署 | GitHub Pages |

## 📦 本地开发

```bash
git clone https://github.com/1917278979xxx-coder/food-preferences.git
cd food-preferences
# 直接用浏览器打开 index.html，或使用 Live Server
```

本地运行时需连接 Supabase 后端，数据库表结构见 `supabase-schema.sql`。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request。

## 📄 许可

MIT License

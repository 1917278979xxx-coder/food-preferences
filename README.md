# 🍽️ 美食偏好管理

一个帮你记住朋友口味与禁忌的轻量级 Web 应用。支持多朋友管理、小组协作、标签筛选、实时云同步、数据导出。

## ✨ 功能

- 👥 **多朋友管理** — 添加多位朋友，分别记录每个人的饮食偏好
- 👨‍👩‍👧 **小组协作** — 创建家庭/好友小组，邀请码加入，组内共享朋友和食物数据
- 📋 **编辑记录** — 小组成员的操作日志，谁在什么时候增删了什么一目了然
- 🔐 **多用户隔离** — 每个账号数据云端独立存储，互不干扰
- 📷 **朋友头像** — 点击头像上传照片，自动缩放存储
- ❤️👎⚠️ **三大分类** — 爱吃 / 不喜欢吃 / 过敏，一目了然
- 🏪🍳 **店铺与菜品标签** — 记录「哪家店的什么菜」，方便后续查找
- 🔍 **标签筛选** — 按店铺或菜品一键筛选所有记录
- ☁️ **云同步** — 基于 Supabase Realtime，多端数据实时同步
- 📊 **数据导出** — 支持导出 CSV（Excel）/ 文本 / PDF
- 📱 **响应式设计** — 手机、平板、电脑都能用

## 🚀 快速开始

访问线上地址：**[1917278979xxx-coder.github.io/food-preferences](https://1917278979xxx-coder.github.io/food-preferences/)**

1. 注册账号（首次使用点「创建账号」）
2. 添加朋友，上传头像，记录饮食偏好
3. 点击底部「小组」tab，创建或加入家庭组
4. 组内所有成员可共享编辑，操作记录可追溯
5. 用筛选条快速查找，随时导出分享

## 🛠️ 技术栈

| 层面 | 技术 |
|------|------|
| 前端 | Vanilla HTML/CSS/JS（单文件应用） |
| 后端 | Supabase（PostgreSQL + Auth + Realtime + RLS） |
| 部署 | GitHub Pages |
| 数据表 | `friends`、`food_items`、`groups`、`group_members`、`edit_logs` |

## 📦 本地开发

```bash
git clone https://github.com/1917278979xxx-coder/food-preferences.git
cd food-preferences
# 直接用浏览器打开 index.html，或使用 Live Server
```

本地运行时需连接 Supabase 后端，数据库迁移脚本见 `groups-migration.sql`。

## 📄 许可

MIT License

# 🍃 Savor · 慢享味觉记忆

> 一本手绘风格的美食备忘录，记录你与朋友的味觉记忆。

一个帮你记住朋友口味与禁忌的轻量级 Web 应用。支持多朋友管理、小组协作、标签筛选、云同步、数据导出。

**线上地址：[1917278979xxx-coder.github.io/food-preferences](https://1917278979xxx-coder.github.io/food-preferences/)**

---

## 🎨 设计

Savor 采用**备忘录手账 / 水彩自然**设计风格：

- 手绘毛边滤镜（SVG wobble）— 卡片、按钮、图标带不规则手绘边缘
- 横线纸背景 + 螺旋装订孔 — 还原真实笔记本质感
- 便签纸卡片 + 胶带装饰 — 圆角不规则、伪元素胶带效果
- 水彩食物插画 — 番茄、牛油果、胡萝卜、沙拉碗
- Fraunces + Noto Serif SC 标题字体，Plus Jakarta Sans 正文字体
- oklch 暖色系 — 鼠尾草绿主色、暖珊瑚强调色
- 暗色模式自动跟随系统

## ✨ 功能

### 个人
- 👥 **多朋友管理** — 添加多位朋友，分别记录每个人的饮食偏好
- ❤️👎⚠️ **三大分类** — 爱吃 / 不喜欢吃 / 过敏，卡片色条区分
- 🏪🍳 **店铺与菜品标签** — 记录「哪家店的什么菜」
- 🔍 **标签筛选** — 按分类、店铺、菜品一键筛选
- 📷 **朋友头像** — 点击上传照片，自动压缩存储
- 📊 **数据导出** — 支持 CSV（Excel）/ 文本 / PDF

### 小组
- 👨‍👩‍👧 **小组协作** — 创建小组，8 位邀请码加入，多人共享编辑
- 📋 **编辑记录** — 活动流时间轴，谁为谁增删了什么一目了然
- 📤 **添加到我的列表** — 一键将小组朋友快照到个人主页，含全部食物记录；个人与小组数据完全隔离，互不影响

### 平台
- 🔐 **多用户隔离** — Supabase Auth（邮箱+密码），RLS 策略保障数据安全
- ☁️ **实时云同步** — Supabase Realtime，多端数据实时同步
- 📱 **响应式** — 桌面侧边栏 / 移动端底部导航，三断点适配

## 🚀 快速开始

1. 注册账号（首次使用点「创建账号」）
2. 添加朋友，记录饮食偏好
3. 切换到「小组」tab，创建或输入邀请码加入小组
4. 组内所有成员可共享编辑，操作记录可追溯
5. 在小组朋友详情页点「添加到我的列表」同步到个人主页
6. 用筛选条快速查找，随时导出分享

## 🛠️ 技术栈

| 层面 | 技术 |
|------|------|
| 前端 | Vanilla HTML/CSS/JS（单文件 ~3900 行） |
| 设计系统 | Savor — SVG wobble 滤镜、水彩插画、便签纸卡片 |
| 字体 | Google Fonts（Fraunces、Plus Jakarta Sans、Noto Serif SC、Noto Sans SC） |
| 后端 | Supabase（PostgreSQL + Auth + Realtime + RLS） |
| 部署 | GitHub Pages（`main` 分支 `/` 根目录） |

### 数据表

| 表 | 用途 |
|----|------|
| `friends` | 朋友列表（user_id、group_id、avatar_url） |
| `food_items` | 食物项（friend_id、category、store_tag、dish_tag） |
| `groups` | 小组（name、invite_code、created_by） |
| `group_members` | 组成员（group_id、user_id、role、nickname） |
| `edit_logs` | 操作日志（action、food_name、friend_id、group_id） |

## 📦 本地开发

```bash
git clone https://github.com/1917278979xxx-coder/food-preferences.git
cd food-preferences
# 直接用浏览器打开 index.html
```

数据库迁移脚本：
- `groups-migration.sql` — 建表 + RLS 策略
- `fix-group-members-rls.sql` — RLS 诊断修复

## 🔧 数据库设置

在 Supabase SQL Editor 中依次运行：

1. `groups-migration.sql` — 建表、开启 RLS、创建安全函数
2. 如遇 RLS 报错，运行 `fix-group-members-rls.sql` 诊断修复

## 📝 更新日志

### 2026-07-15
- 🎨 **Savor 备忘录风格 UI 重构** — oklch 暖色、便签卡片、水彩插画、侧边栏布局、Overview 仪表盘
- 🐛 修复 CSS 优先级导致登录后页面无法跳转
- 🐛 修复视图切换 ID 映射 bug
- 🐛 修复 `group_members` RLS 策略缺失
- 🔧 个人/小组数据完全隔离 — 快照复制替代实时引用

### 2026-06-20
- 🎨 手绘蜡笔风 UI（V2）— SVG 插画、龙藏体、纸张纹理
- 🎨 UI 全面升级（V1）— Material Symbols 图标、毛玻璃、骨架屏
- 🐛 修复小组跨账号数据不可见、编辑记录不显示等多项 bug
- ✨ 新增小组功能、编辑记录、添加到我的列表

## 📄 许可

MIT License

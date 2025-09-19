# FFAA - 随时随地查找应用

一个 Flutter 开发的跨平台应用查找工具，支持快速浏览和启动系统中的应用。

## 功能特性

### 核心功能

- ✅ macOS 应用列表扫描（/Applications 目录）
- ✅ 应用信息展示（名称、图标、Bundle ID、版本）
- ✅ 双视图切换（网格视图/列表视图）
- ✅ 应用搜索功能
- ✅ 应用启动和 Finder 中显示
- ✅ 右键上下文菜单

### 平台支持

- ✅ **macOS**: 完整支持
- 🔄 其他平台: 待实现（返回"未实现"提示）

## 技术架构

### 目录结构

```
lib/
├── models/          # 数据模型
│   └── app_info.dart
├── services/        # 平台服务
│   ├── platform_service.dart
│   └── macos_app_service.dart
├── utils/           # 工具类
│   └── app_launcher.dart
├── widgets/         # 自定义组件
│   └── app_icon_widget.dart
├── pages/           # 页面组件
│   └── home_page.dart
└── main.dart        # 应用入口
```

### 设计特点

- **响应式布局**: 支持窗口大小变化，自动调整网格布局
- **悬停效果**: 鼠标悬停时显示边框反馈
- **触控优化**: 精确的触控响应区域
- **错误处理**: 完善的异常处理和用户提示

## 安装和运行

### 环境要求

- Flutter 3.0+
- Dart 3.0+
- macOS 10.15+

### 运行命令

```bash
# 开发模式运行
flutter run

# Release模式运行
flutter run --release

# 构建macOS应用
flutter build macos
```

## 使用说明

1. **应用列表**: 首页自动加载系统中的应用
2. **视图切换**: 点击右上角图标切换网格/列表视图
3. **搜索功能**: 在搜索框中输入应用名称进行过滤
4. **启动应用**: 点击应用图标或列表项启动应用
5. **右键菜单**: 右键点击应用显示更多操作选项
   - 打开应用
   - 在 Finder 中显示
   - 查看应用信息

## 开发说明

### 添加新平台支持

1. 在 `lib/services/` 下创建新的平台服务类
2. 实现 `PlatformService` 接口
3. 在 `platform_service.dart` 中添加平台判断逻辑

### 自定义样式

修改 `lib/widgets/app_icon_widget.dart` 中的样式配置：

- 图标尺寸
- 边框颜色和宽度
- 悬停效果
- 文本样式

## 许可证

MIT License

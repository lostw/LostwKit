# lostwKit

## 版本日志
### 2.2.0
1. 完善ZZError类
2. 统一文件持久化存储与缓存的方法
3. 加入PreCacheResrouce，并且包内文件不再必须
4. 调整了WebViewJavascriptBridge的文字

### 2.1.5

1. 修改[WKWebViewJavascriptBridge](https://github.com/Lision/WKWebViewJavascriptBridge)并内置到LostwKit中，用于替换OC版的WebViewJavascriptBridge。修改是为了兼容WebViewJavascriptBridge的调用方式
2. 修改H5BridgeConfiguration协议对调用入口方式做了统一
3. 增加了线程安全的KeychainSafeDictWrapper
4. 使用并行队列改写了MemoryCache(之前使用pthread_mutex_t), 意图解决并发闪退的问题【待验证】

### 2.1.0

1. 移除Mapable协议，方法迁移到Codable
2. String上手机号、身份证的校验方法移到扩展的checker对象上
3. DiskFileManager增加错误日志输出，现在内部会对key做sha256
4. 简化ZLog的封装，对外部使用不影响
5. ZZError扩展了内部支持
6. H5PageController增加了地址无效的提示
7. WebManager增加了返回手势支持
8. ApiRule调整，但使用仍觉得不行
9. Indicator的runloop监听明确改到主线程
10. 移除了一些iOS 10以下的兼容性支持

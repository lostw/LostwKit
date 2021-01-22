# lostwKit

## 版本日志

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
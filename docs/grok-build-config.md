### GrokBuild配置方法

通过`which grok` 发现自动安装器会将二进制放在 `~/.local/bin/grok`

### custom provider 配置方法

编辑` ~/.grok/config.toml`

```toml

# 对于grok-build而言，1个模型占用一个基础字段
# 即使同一供应商，两个模型也会占用两个字段。如，GPT5.6Sol/GPT6.0Astra虽然全部来自于openai,但是会占用两个字段
telemetry = false # 关闭遥测

[models]
default = "填入你的定义" # 这个地方可以在内部用/model改


# 一个模型配置示例


[model.定义名]
model = "模型ID"
base_url = "https://xxx/v1" # 具体看你供应商上游、格式
api_key = "SK-XXXXX" # 也可以通过环境变量传入，但是标头改为：env_key = "变量名"
context_window = #这里填入上下文窗口，必须是整数
api_backend = "" 接口类型

# 坑点：上文“定义名” 在语义抽象上，应该理解为alias. 也就是说，你将其定义为比如什么KnucklesDoesntGiveaFlyingFxxk什么的名字都可以
# 但是！！！！注意，点号会被toml解析为分割符
# e.g. Qwen3.8flash 这个字段 在 toml解析器看来是
# Qwen3 |和| 8flash 两个字段 直接解析失败
# 现在模型迭代都喜欢用数字.数字当版本号。严格来说，这里语义坍缩了，务必注意。

```


 

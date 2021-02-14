# wind-ltask
A server framework with [ltask](https://github.com/cloudwu/ltask)

### 简介
```
wind-ltask 是以云大的 ltask 为核心的服务器框架, 由于ltask目前十分精简而且还没有放出文档,
所以这个项目是一个提前体验 ltask 的框架。

根据测试 lsocket 的表现 与skynet的表现还是有一定差距(tcp 响应时间多几毫秒, 也不稳定), 所以暂时先等待云大的更新了。
```

### 主要功能
```
1.网关, 基于 lsocket 的一个独占线程服务
2. 集成数据库驱动, 目前已集成 lua-mongo
3. 日志服务
```

### 出发! (小白环境配置教程)
```
1. 选一台 linux 服务器 (推荐 centos) (root用户下操作)

2. 安装 lua-5.4.2
	curl -R -O http://www.lua.org/ftp/lua-5.4.2.tar.gz
	tar zxf lua-5.4.2.tar.gz
	cd lua-5.4.2
	make all test
	make install

3. 依赖安装, 3rd 下面有若干 lualib, 基本上就是make, 然后把库文件拷贝到项目目录下  

4. 由于wind-ltask 包含了 ltask 的源码, 所以接下来
	git clone https://github.com/HYbutterfly/wind-ltask.git
	cd wind-ltask
	make
	
5. 启动服务器 (目前只是一个echo服务)
	lua main.lua
	另开一个终端 输入 nc 127.0.0.1 8888 并输入一些内容
	enjoy it! :)

```

### Tips
```
由于是本人服务器是单核的, config.c 里有个小小的修改 来跳过报错, 其他没有修改
	if (ncores <= 1) {
		// luaL_error(L, "Need at least 2 cores");
		// return;
		ncores = 2;
	}

```
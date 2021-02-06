# wind-ltask
A server framework with [ltask](https://github.com/cloudwu/ltask)

### 简介
```
wind-ltask 是以云大的 ltask 为核心的服务器框架, 由于ltask目前十分精简而且还没有放出文档,
所以这个项目是一个提前体验 ltask 的框架
```

### 主要功能
```
1.网关, 基于 luasocket 的一个独占线程服务


-- TODO
2. 集成数据库驱动, 优先 mongo, mysql
3. 日志服务
4. 热更新, 这个业务上还经常用到, 不停机修复BUG, 但应该也是个难点
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

3. 安装 lua 包管理器 luarocks
	wget https://luarocks.org/releases/luarocks-3.5.0.tar.gz
	tar zxpf luarocks-3.5.0.tar.gz
	cd luarocks-3.5.0
	./configure && make && sudo make install

4. 安装 luasocket
	luarocks install luasocket --lua-version 5.4

5. 由于wind-ltask 包含了 ltask 的源码, 所以接下来
	git clone https://github.com/HYbutterfly/wind-ltask.git
	cd wind-ltask
	make
	
6. 启动服务器 (目前只是一个echo服务)
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
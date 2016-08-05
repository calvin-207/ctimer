# ctime 服务
----

## 目标
解决业务中大量的定时任务、自旋锁功能。

因为erlang的erlang:send_after是时间轮的实现方式，在大量使用的前提下会对整个系统带来比较大的损耗。

timer提供了类似的工作，但是因为其是单进程工作，如果直接使用或者被大量使用的情况下效果也是比较难控制，所以最终选择了自己实现一套ctimer,同事提供关于时间的一套公用的接口。

## 使用

- 启动app

application:start(ctimer)

- 启动服务

ctimer_sup:start_chile(Name)

启动一条名字为Name的ctimer_server进程

- 注册秒轮训服务

ctimer:register(CtimeServerName, Dest, sec_loop)

改命令会在CtimerServerName的ctimer_server注册 sec_loop服务，并且接受目标为Dest。 注册后 Dest进程会每秒收到 {sec_loop, NowSec} 消息。

如果Dest进程销毁或者取消该循环 需要执行 ctimer:unregister(CtimerServerName, Dest, sec_loop)

##



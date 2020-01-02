# freeswitch 功能脚本

### 1 限制呼叫次数
#### 1.1 脚本
  ```shell
  route/call_limit.lua
  ```
#### 1.2 功能
  + 限制每天呼叫次数
  + 限制每月呼叫次数  
#### 1.3 api 命令
  + 重置全部计数器
  ```shell
  > lua route/call_limit.lua reset all
  ```  
  + 重置`每天呼叫`计数器
  ```shell
  > lua route/call_limit.lua reset count-of-day all
  ```
  + 重置一个`key`的`每天呼叫`计数器，key可以是一个gateway名，一个号码等
  ```shell
  > lua route/call_limit.lua reset count-of-day 862863484444
  ```
  + 重置`每月呼叫`计数器
  ```shell
  > lua route/call_limit.lua reset count-of-mouth all
  ```
  + 重置一个`key`的`每月呼叫`计数器，key可以是一个gateway名，一个号码等
  ```shell
  > lua route/call_limit.lua reset count-of-mouth 862863484444
  ```  
#### 1.4 拨号计划
  + 限制每天呼叫次数,如：gateway名称是`862868355865`，每天最多呼`100`次
  ```xml
     <extension name="call-ims-from-862868355865">
      <condition field="${lua(route/call_limit.lua count-of-day 862868355865 100)}" expression="^true$"/>
	  <condition field="destination_number" expression="^(\d+)$">
	    <action application="bridge" data="sofia/gateway/68355865/$1"/>
      </condition>
    </extension> 
  ```
  + 限制每月呼叫次数,如：gateway名称是`862868355865`，每月最多呼`10000`次
  ```xml
     <extension name="call-ims-from-862868355865">
      <condition field="${lua(route/call_limit.lua count-of-month 862868355865 10000)}" expression="^true$"/>
	  <condition field="destination_number" expression="^(\d+)$">
	    <action application="bridge" data="sofia/gateway/68355865/$1"/>
      </condition>
    </extension> 
  ```
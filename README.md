&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;伴随着苹果新的IDE的发布,swift4.0也随之而来,4.0版本新的接口大家已经尝试使用过了,4.0较之前版本稳定性和兼容性有了很大的提升,这也说明苹果的官方接口趋向于稳定,对我们开发者来说是一个好消息.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;好了,废话不多说,直接切入正题,最近用开发了一个小的项目.前端代码纯swift编写,基本页面已经编写完成,下面首先将展示一下登录注册模块.后端接口用Python3.0+编写,只是部分接口,下一步工作将完善后端接口.项目是完全仿照Twitter 客户端编写,里面的图标有的能盗取的就盗取(罪过罪过),盗取不了的就自己ps了一下,当年我也是学了半年ps, 他么的还真有用到的时候.

## 一. 项目主要架构模式:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.1 尽量采用现在比较流行的MVVM(model,view,viewModel),这些层之间的数据交换以及数据传递和绑定,在这里不细说了,网上博客一大堆,介绍的很详细.需要的可以搜索一下,详细看看.我按照自己的理解这里举一个简单的使用例子=>关于页面是一个列表页面:

![图1.1 关于页面(登录页面右上角按钮触发)](https://upload-images.jianshu.io/upload_images/1715253-7e6c4ac7164a1a17.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.2 列表的数据源来自MTTAboutViewModel,MTTAboutViewModel通过一个类方法将数据回调给MTTAboutTwitterViewController, MTTAboutTwitterViewController将数据传给cell(view).MTTAboutTwitterViewController不负责数据的请求以及业务处理.

![图1.2 MTTAboutViewModel数据请求处理](https://upload-images.jianshu.io/upload_images/1715253-e26ad030d2ff728e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

1.3 将数据回调给VC:
![图1.3  VC获取viewModel回调过来的数据](https://upload-images.jianshu.io/upload_images/1715253-4ba934e05c919217.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

1.4 view显示
![图1.4 view显示数据](https://upload-images.jianshu.io/upload_images/1715253-6ab558991c0764b5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

## 二. 项目主要技术和第三方框架:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;项目的架构主要采用mvvm模式,布局采用的是SnapKit(3.0+版本),4.0版本还没有release,暂时没有当他们的小白鼠.之前用过用过Masonry的上手很容易,这里也不多废话了.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;网络用的是Alamofire,自己为了数据回调方便又在外面套了一层(纯粹装B),异步以及线程安全方面的处理和AFN一样,使用者需要关心的很少,除非有特别需求的单独封装.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;json数据解析用的SwiftyJSON,json数据解析框架网上有好多,各家都说自己的性能很棒,我用惯了SwiftyJSON,性能方面没有监测过.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;事件流的监控用的是RxSwift,之前用过ReactiveCocoa,ReactiveCocoa也有自己的swift版本,两者都属于响应式编程框架,在语法上还是有很大区别.学习RxSwift比一门新的语言学习起来还要难受(个人感觉),不过基本用法掌握后使用起来很方便,具体实现可以参考项目中的代码.

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;还有其他方面的,比如设计模式什么的,太多,大家有兴趣的可以把项目克隆下来看看.

## 三 .项目结构主要分为:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;由于内容较多,这次先上几张登录注册模块图,并且把前端和后端代码地址放上,有需要的可以下载下来看看,任何问题都可以沟通学习,留言讨论,交换想法,也可以加我qq=284485487,我太多不懂,希望大家多指点指点,不麻烦的话给个赞或者star,谢谢!
### 前台代码地址:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;https://github.com/waitwalker/MyTwitter

### 后台代码地址:  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;https://github.com/waitwalker/MyTwitterAPI

### 3.1 登录&注册:

![3.1-1 登录注册](https://upload-images.jianshu.io/upload_images/1715253-0ac28327a678d9d2.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

![3.1-2 登录注册](https://upload-images.jianshu.io/upload_images/1715253-d3c1a942b5172fff.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)


![3.1-3 登录注册](https://upload-images.jianshu.io/upload_images/1715253-1c06dc7eedb2ec75.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

![3.1-4 登录注册](https://upload-images.jianshu.io/upload_images/1715253-82f3e95e86e340a5.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

![3.1-5 登录注册](https://upload-images.jianshu.io/upload_images/1715253-82f3e95e86e340a5.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)


### 3.2 首页
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;首页页面,目前实现首页发推功能


![首页页面](https://upload-images.jianshu.io/upload_images/1715253-18161e97459cec50.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

![发推页面](https://upload-images.jianshu.io/upload_images/1715253-0245434b010b04bd.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)



![选择相片](https://upload-images.jianshu.io/upload_images/1715253-a5aae56c642a3dc1.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)


### 3.3 搜索

![搜索页面](https://upload-images.jianshu.io/upload_images/1715253-7b41c8a9205b4544.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)


### 3.4 通知

![通知页面](https://upload-images.jianshu.io/upload_images/1715253-68f9e46124d6297a.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

### 3.5 私信



![私信页面](https://upload-images.jianshu.io/upload_images/1715253-a90ffb5b6a14294b.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)




## 四. 后台接口
![4.1 后台接口](https://upload-images.jianshu.io/upload_images/1715253-24de6f1a3dbd7c7b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)
### 东西太多,一次写不了太多,未完待续...
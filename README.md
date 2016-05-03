#####1、PhotoKit是什么？

PhotoKit是苹果给我们提供的一个处理相册资源的库。以前使用[AssetsLibrary 框架](https://developer.apple.com/library/ios/documentation/AssetsLibrary/Reference/ALAssetsLibrary_Class/#//apple_ref/doc/uid/TP40009722-CH1-SW57) ， 相机应用和照片应用发生了显著的变化，增加了许多新特性，包括按时刻来组织照片的方式。但与此同时，AssetsLibrary 框架落伍了，iOS 8 开始苹果引入PhotoKit 。

#####2、本文示例

本文主要了解PhotoKit的基本使用，效果图：

![项目配图](http://upload-images.jianshu.io/upload_images/954071-5474c8bfa8375bb1.gif?imageMogr2/auto-orient/strip)

记得以前在简书也写过一篇有关相册的文章，当时用的AssetsLibrary 框架 也有一些问题，[Swift中实现相册的多选](http://www.jianshu.com/p/8c89cac09387) 就是这篇，建议大家以后尽量使用PhotoKit进行相册管理。

上图点击完成，图片是以闭包的形式返回，闭包传入[PHAsset] 数组供使用，使用的时候还需要传入一个参数，最多选择照片个数，我这里传入的是4.

在vc中使用很简单就一句话。
```
self.zz_presentPhotoVC(4){ (assets) in
            print(assets.count)
        }   
```

本来是想讲解下PhotoKit的使用的，但其实自己对此框架没有很多的见解，大多数都是看官方文档还有一些优质的blog，我想说的其他的blog都讲的很详细了，直接直接放上连接，和自己练习的源码地址。供大家学习使用。

3、学习资源和代码

- [obc中国](http://objccn.io/issue-21-4/)
- [简书小伙伴写的 不错](http://www.jianshu.com/p/42e5d2f75452)
- [官方示例代码oc版本](https://developer.apple.com/library/ios/samplecode/UsingPhotosFramework/Introduction/Intro.html#//apple_ref/doc/uid/TP40014575 )
- [WWDC PhotoKit 视频地址](https://developer.apple.com/videos/play/wwdc2014/511/ )
- [上面gif的代码地址(swift)](https://github.com/smalldu/ZZImagePicker)


######2016年4月29更新
 模仿微信，将照片库中只能相册为0的cell去掉，所有分组合成一个section，并排序 ，优化页面显示 ，修改选中模式，添加预览模式（暂时还没做）
如图：

![配图](http://upload-images.jianshu.io/upload_images/954071-38af19cb1b9bf431.gif?imageMogr2/auto-orient/strip)

![手机截图](http://upload-images.jianshu.io/upload_images/954071-11fadba6f7d985db.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如果大于最大可选择数量，会左右摇摆提示。
后面完成预览功能会再来更新。
有什么好的建议也可以提出来

//
//  ZYQRScanner.h
//  ZYQRScanner
//
//  Created by 换一换 on 16/12/16.
//  Copyright © 2016年 换一换. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+MDQRCode.h"
@protocol QRCodeScanneDelegate <NSObject>
/**
 *  扫描成功后返回扫描结果
 *
 *  @param result 扫描结果
 */
- (void)didFinshedScanningQRCode:(NSString *)result;

@end

@interface ZYQRScanner : UIView
/**
 扫描线
 */
@property (nonatomic, strong) UIView *scanLine;

/**
 扫描线颜色
 */
@property (nonatomic, strong) UIColor *scanningLineColor;

/**
 扫描线往返时间
 */
@property (nonatomic, strong) NSTimer *scanLineTimer;

/**
 四个边框颜色
 */
@property (nonatomic, strong) UIColor *cornerLineColor;

/**
 提示label
 */
@property (nonatomic, strong) UILabel *promptLabel;

/**
 闪光灯按钮
 */
@property (nonatomic, strong) UIButton *lightBtn;

/**
 是否打开照明
 */
@property (nonatomic, assign) BOOL isOn;
/**
 透明扫描框区域大小
 */
@property (nonatomic, assign) CGSize transparentAreaSize;

/**
 中间透明扫描区域
 */
@property (nonatomic, assign) CGRect clearDrawRect;

/**
 AVFoundation详解 http://www.cnblogs.com/kenshincui/p/4186022.html#camera
 */

/**
 媒体（音、视频）捕获会话，负责把捕获的音视频数据输出到输出设备中
 */
@property (nonatomic,strong)AVCaptureSession *session;

/**
 相机拍摄预览图层
 */
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *preview;

/**
 设备输入数据管理对象
 */
@property (nonatomic,strong)AVCaptureDeviceInput * input;

/**
 输出数据管理对象
 */
@property (nonatomic,strong)AVCaptureMetadataOutput * output;

/**
 输入设备
 */
@property (nonatomic,strong)AVCaptureDevice * device;


/**
 *  扫描结果代理
 */
@property (nonatomic,assign) id<QRCodeScanneDelegate>delegate;

/**
 初始化方法

 @param view 父view

 @return scanner实例
 */
-(instancetype)initQRScnnerWithView:(UIView *)view;


//二维码生成方法

/**
 根据字符串生成一个给定尺寸,给定颜色的二维码
 
 @param string    字符串
 @param size      大小
 @return 二维码
 */
+(UIImage *)zyQRWithString:(NSString *)string size:(CGFloat)size;

/**
 根据字符串生成一个给定尺寸,给定颜色的二维码

 @param string    字符串
 @param size      大小
 @param fillColor 二维码填充颜色 默认黑色

 @return 二维码颜色
 */
+(UIImage *)zyQRWithString:(NSString *)string size:(CGFloat)size fillColor:(UIColor *)fillColor;

/**
 根据字符串和图片 生成一个中间带图片的二维码

 @param string    字符串
 @param size      大小
 @param fillColor 填充颜色
 @param subImage  图片

 @return 二维码
 */
+(UIImage *)zyQRWithString:(NSString *)string size:(CGFloat)size fillColor:(UIColor *)fillColor subImage:(UIImage *)subImage;


/**
 从图片中读取二维码

 @param image 带有二维码的图片

 @return 二维码信息
 */
+(NSString *)zyQRReadForImage:(UIImage *)image;
@end

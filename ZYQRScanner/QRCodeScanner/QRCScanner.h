//
//  QRCScanner.h
//  QRScannerDemo
//
//  Created by zhangfei on 15/10/15.
//  Copyright © 2015年 zhangfei. All rights reserved.
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

@interface QRCScanner : UIView
/**
 *  扫描线的颜色,默认红色
 */
@property (nonatomic,strong)UIColor *scanningLieColor;
/**
 *  扫描框边角的颜色，默认红色
 */
@property (nonatomic,strong)UIColor *cornerLineColor;
/**
 *  扫描框的宽高区域，默认(200，200)
 */
@property (nonatomic,assign)CGSize transparentAreaSize;
/**
 *  代理
 */
@property (nonatomic,assign) id<QRCodeScanneDelegate>delegate;



@property (nonatomic,strong)NSTimer *scanLineTimer;
@property (nonatomic,strong)UIView *scanLine;
@property (nonatomic,strong)UILabel *noticeInfoLable;
@property (nonatomic,strong)UIButton *lightButton;

@property (nonatomic,assign)CGRect clearDrawRect;
@property (nonatomic,assign)BOOL isOn;

@property (nonatomic,strong)AVCaptureSession *session;
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *preview;
@property (nonatomic,strong)AVCaptureDeviceInput * input;
@property (nonatomic,strong)AVCaptureMetadataOutput * output;
@property (nonatomic,strong)AVCaptureDevice * device;




/**
 *  初始化方法
 *
 *  @param QRCScannerView的父view
 *
 *  @return QRCScanner实例
 */
- (instancetype)initQRCScannerWithView:(UIView *)view;
/**
 *  根据给定的字符串生成一个给定尺寸的二维码image
 *
 *  @param qrString 二维码的内容
 *  @param size     二维码生成后的尺寸大小
 *
 *  @return 二维码
 */
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)size;
/**
 *  根据给定的字符串生成一个给定尺寸和给定颜色的二维码image
 *
 *  @param qrString  二维码的内容
 *  @param size      二维码生成后的尺寸大小
 *  @param fillColor 二维码填充颜色
 *
 *  @return 二维码
 */
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)fillColor;
/**
 *  生成中间有logo的二维码
 *
 *  @param qrString  二维码的内容
 *  @param size      二维码生成后的尺寸大小
 *  @param fillColor 二维码填充颜色
 *  @param subImage  二维码的子图
 *
 *  @return 带有子图的二维码
 */
+ (UIImage *)scQRCodeForString:(NSString *)qrString size:(CGFloat)size fillColor:(UIColor *)fillColor subImage:(UIImage *)subImage;
/**
 *  从图片中读取二维码
 *
 *  @param qrimage 一张二维码图片
 *
 *  @return 二维码信息
 */
+ (NSString *)scQRReaderForImage:(UIImage *)qrimage NS_AVAILABLE_IOS(8_0);
@end

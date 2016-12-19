//
//  ZYQRScanner.m
//  ZYQRScanner
//
//  Created by 换一换 on 16/12/16.
//  Copyright © 2016年 换一换. All rights reserved.
//

#import "ZYQRScanner.h"

#define LINE_SCAN_TIME  2.0     // 扫描线从上到下扫描所历时间（s）

#define kHeight      [[UIScreen mainScreen] bounds].size.height
#define kWidth       [[UIScreen mainScreen] bounds].size.width
#define kScal kWidth/375
@interface ZYQRScanner() <AVCaptureMetadataOutputObjectsDelegate>

@end
@implementation ZYQRScanner
-(instancetype)initQRScnnerWithView:(UIView *)view
{
    ZYQRScanner *qrc = [[ZYQRScanner alloc] initWithFrame:view.frame];
    [qrc initDataWithView:view];
    return qrc;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _transparentAreaSize = CGSizeMake(200 * kScal, 200 * kScal);
        _cornerLineColor = [UIColor redColor];
        _scanningLineColor = [UIColor redColor];
    }
    return self;
}
-(void)drawRect:(CGRect)rect
{
    [self updateLayout];
}

#pragma mark - setter and getter
- (void)setTransparentAreaSize:(CGSize)transparentAreaSize{
    _transparentAreaSize = transparentAreaSize;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setScanningLieColor:(UIColor *)scanningLieColor{
    _scanningLineColor = scanningLieColor;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setCornerLineColor:(UIColor *)cornerLineColor{
    _cornerLineColor = cornerLineColor;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)updateLayout
{
   //cgrect
    CGRect screenDrawRect = CGRectMake(0, 0, kWidth, kHeight);
    
    CGSize transparentArea = _transparentAreaSize;
    
    //
    _clearDrawRect = CGRectMake(kWidth/2 - transparentArea.width/2, kHeight / 2 - transparentArea.height/2, transparentArea.width, transparentArea.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self addScreenFillRect:ctx rect:screenDrawRect];
    [self addCenterClearRect:ctx rect:_clearDrawRect];
    [self addWhiteRect:ctx rect:_clearDrawRect];
    [self addCornerLineWithContext:ctx rect:_clearDrawRect];
    [self addScanLine:_clearDrawRect];
    [self addPromptLabel:_clearDrawRect];
    [self addLightBtn:_clearDrawRect];
    if (self.scanLineTimer == nil) {
        [self moveUpAndDownLine];
        [self creatTimer];
    }
    
}
#pragma mark 添加提示label
-(void)addPromptLabel:(CGRect)rect
{
    _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (rect.origin.y + rect.size.height + 10), kWidth, 20 * kScal)];
    [_promptLabel setText:@"将二维码或条形码放入取景框即可自动扫描"];
    _promptLabel.font = [UIFont systemFontOfSize:15 * kScal];
    [_promptLabel setTextColor:[UIColor whiteColor]];
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_promptLabel];
}
#pragma mark 添加手电筒功能按钮
-(void)addLightBtn:(CGRect)rect
{
    _lightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, (rect.origin.y + rect.size.height + 40), kWidth, 20)];
    [_lightBtn setTitle:@"打开照明" forState:UIControlStateNormal];
    [_lightBtn addTarget:self action:@selector(lightSwitch:) forControlEvents:UIControlEventTouchUpInside];
    [_lightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _isOn = NO;
    [self addSubview:_lightBtn];
}
-(void)lightSwitch:(id)sender
{
    if (!_isOn) {
        [_lightBtn setTitle:@"关闭照明" forState:UIControlStateNormal];
        _isOn = YES;
    }else{
        [_lightBtn setTitle:@"打开照明" forState:UIControlStateNormal];
        _isOn = NO;
    }
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    if (device.hasTorch) {  // 判断设备是否有闪光灯
        BOOL b = [device lockForConfiguration:&error];
        if (!b) {
            if (error) {
                NSLog(@"lock torch configuration error:%@", error.localizedDescription);
            }
            return;
        }
        device.torchMode =
        (device.torchMode == AVCaptureTorchModeOff ? AVCaptureTorchModeOn : AVCaptureTorchModeOff);
        [device unlockForConfiguration];
    }
}

#pragma mark 画背景
-(void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextSetRGBFillColor(ctx, 40 /255.0, 40 / 255.0, 40/255.0, 0.5);
    CGContextFillRect(ctx, rect);
}
#pragma mark 扣扫描框
-(void)addCenterClearRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextClearRect(ctx, rect);
}
#pragma mark 画框的白线
-(void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect
{
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 0.8);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}
#pragma mark 画扫描线
-(void)addScanLine:(CGRect)rect
{
    self.scanLine = [[UIView alloc] initWithFrame:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 1)];
    self.scanLine.backgroundColor = _scanningLineColor;
    [self addSubview:self.scanLine];
}
#pragma mark 画框的四个角
-(void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect
{
    //画四个边角
    CGContextSetLineWidth(ctx, 2);
    [self setStrokeColor:_cornerLineColor withContext:ctx];
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x+0.7, rect.origin.y),
        CGPointMake(rect.origin.x+0.7 , rect.origin.y + 15)
    };
    
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y +0.7),CGPointMake(rect.origin.x + 15, rect.origin.y+0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x+ 0.7, rect.origin.y + rect.size.height - 15),CGPointMake(rect.origin.x +0.7,rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - 0.7) ,CGPointMake(rect.origin.x+0.7 +15, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - 15, rect.origin.y+0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y +0.7 )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width-0.7,rect.origin.y + 15 +0.7 )};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7 , rect.origin.y+rect.size.height+ -15),CGPointMake(rect.origin.x-0.7 + rect.size.width,rect.origin.y +rect.size.height )};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - 15 , rect.origin.y + rect.size.height-0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height - 0.7 )};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}
- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}
//设置画笔颜色
- (void)setStrokeColor:(UIColor *)color withContext:(CGContextRef)ctx{
    NSMutableArray *rgbColorArray = [self changeUIColorToRGB:color];
    CGFloat r = [rgbColorArray[0] floatValue];
    CGFloat g = [rgbColorArray[1] floatValue];
    CGFloat b = [rgbColorArray[2] floatValue];
    CGContextSetRGBStrokeColor(ctx,r,g,b,1);
}
#pragma mark - 创建计时器
-(void)creatTimer
{
    self.scanLineTimer = [NSTimer scheduledTimerWithTimeInterval:LINE_SCAN_TIME target:self selector:@selector(moveUpAndDownLine) userInfo:nil repeats:YES];
}
-(void)moveUpAndDownLine
{
  
    CGSize viewFinderSize = _clearDrawRect.size;
    CGRect scanLineFrame = self.scanLine.frame;
    scanLineFrame.origin.y = (kHeight - viewFinderSize.height)/2;
    self.scanLine.frame = scanLineFrame;
    self.scanLine.hidden = NO;
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:LINE_SCAN_TIME- 0.05 animations:^{
        CGRect scanLineFrame = weakSelf.scanLine.frame;
        scanLineFrame.origin.y = (kHeight + viewFinderSize.height)/2 - weakSelf.scanLine.frame.size.height;
        weakSelf.scanLine.frame = scanLineFrame;
    } completion:^(BOOL finished) {
        weakSelf.scanLine.hidden = YES;
    }];
    
}

-(void)initDataWithView:(UIView *)view
{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }
    
    //增加条形码扫描
    _output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                    AVMetadataObjectTypeEAN8Code,
                                    AVMetadataObjectTypeCode128Code,
                                    AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResize;
    [_preview setFrame:view.bounds];
    [view.layer insertSublayer:_preview atIndex:0];
    
    [_session startRunning];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    [self.session stopRunning];
    //[self.preview removeFromSuperlayer];
    
    //设置界面显示扫描结果
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        if ([self.delegate respondsToSelector:@selector(didFinshedScanningQRCode:)]) {
            [self.delegate didFinshedScanningQRCode:obj.stringValue];
        }
        else{
            NSLog(@"没有收到扫描结果，看看是不是没有实现协议！");
        }
    }
    // [self removeFromSuperview];
}
#pragma mark  - 辅助方法
//将UIColor转换为RGB值
- (NSMutableArray *) changeUIColorToRGB:(UIColor *)color
{
    NSMutableArray *RGBStrValueArr = [[NSMutableArray alloc] init];
    NSString *RGBStr = nil;
    //获得RGB值描述
    NSString *RGBValue = [NSString stringWithFormat:@"%@",color];
    //将RGB值描述分隔成字符串
    NSArray *RGBArr = [RGBValue componentsSeparatedByString:@" "];
    //获取红色值
    float r = [[RGBArr objectAtIndex:1] floatValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%f",r];
    [RGBStrValueArr addObject:RGBStr];
    //获取绿色值
    float g = [[RGBArr objectAtIndex:2] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%f",g];
    [RGBStrValueArr addObject:RGBStr];
    //获取蓝色值
    float b = [[RGBArr objectAtIndex:3] intValue] * 255;
    RGBStr = [NSString stringWithFormat:@"%f",b];
    [RGBStrValueArr addObject:RGBStr];
    //返回保存RGB值的数组
    return RGBStrValueArr;
}
+ (UIImage *)addSubImage:(UIImage *)img sub:(UIImage *) subImage
{
    //get image width and height
    int w = img.size.width;
    int h = img.size.height;
    int subWidth = subImage.size.width;
    int subHeight = subImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //create a graphic context with CGBitmapContextCreate
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGContextDrawImage(context, CGRectMake( (w-subWidth)/2, (h - subHeight)/2, subWidth, subHeight), [subImage CGImage]);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return [UIImage imageWithCGImage:imageMasked];
    //  CGContextDrawImage(contextRef, CGRectMake(100, 50, 200, 80), [smallImg CGImage]);
}
#pragma mark - 对二维码生成的封装
+(UIImage *)zyQRWithString:(NSString *)string size:(CGFloat)size
{
    return [UIImage mdQRCodeForString:string size:size];
}

+(UIImage *)zyQRWithString:(NSString *)string size:(CGFloat)size fillColor:(UIColor *)fillColor
{
    return [UIImage mdQRCodeForString:string size:size fillColor:fillColor];
}
+(UIImage *)zyQRWithString:(NSString *)string size:(CGFloat)size fillColor:(UIColor *)fillColor subImage:(UIImage *)subImage
{
    UIImage *qrImage = [UIImage mdQRCodeForString:string size:size fillColor:fillColor];
    return [self addSubImage:qrImage sub:subImage];
}
#pragma mark  - 从图片中读取二维码
+(NSString *)zyQRReadForImage:(UIImage *)image
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    CIImage *tempimage = [CIImage imageWithCGImage:image.CGImage];
    NSArray *features = [detector featuresInImage:tempimage];
    CIQRCodeFeature *feature = [features firstObject];
    NSString *result = feature.messageString;
    NSLog(@"%@",result);
    return result;
}





@end

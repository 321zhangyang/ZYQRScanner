//
//  ShowViewController.m
//  ZYQRScanner
//
//  Created by 换一换 on 16/12/19.
//  Copyright © 2016年 换一换. All rights reserved.
//

#import "ShowViewController.h"
#import "ZYQRScanner.h"
#import "QRCScanner.h"
@interface ShowViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIImageView *resultImg;
@property (weak, nonatomic) IBOutlet UILabel *information;

@end

@implementation ShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resultLabel.text = self.result;
    
    UIImage *image = [ZYQRScanner zyQRWithString:self.result size:200 fillColor:[UIColor colorWithRed:1/255.0 green:1/255.0 blue:1/255.0 alpha:1]];
    self.resultImg.image = image;
    
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)recognition:(id)sender {
    
 //   self.information.text = [ZYQRScanner zyQRReadForImage:self.resultImg.image];
    
    //截取的图片可以识别 自己生成的二维码也可以 但是有个问题 如果是纯黑色 就识别不了 不知道问题出在哪里
    self.information.text = [QRCScanner scQRReaderForImage:self.resultImg.image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

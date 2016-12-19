//
//  ScanViewController.m
//  ZYQRScanner
//
//  Created by 换一换 on 16/12/19.
//  Copyright © 2016年 换一换. All rights reserved.
//

#import "ScanViewController.h"
#import "ZYQRScanner.h"
#import "ShowViewController.h"
@interface ScanViewController ()<QRCodeScanneDelegate>
@property (nonatomic , strong) ZYQRScanner *scanner;

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scanner = [[ZYQRScanner alloc] initQRScnnerWithView:self.view];
    self.scanner.delegate = self;
    [self.view addSubview:self.scanner];
    // Do any additional setup after loading the view.
}
-(void)didFinshedScanningQRCode:(NSString *)result
{
    NSLog(@"%@",result);
    
    ShowViewController *show = [[ShowViewController alloc] init];
    show.result = result;
    [self.navigationController pushViewController:show animated:YES];
    // [self.navigationController pushViewController:show animated:YES];
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

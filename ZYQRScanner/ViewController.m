//
//  ViewController.m
//  ZYQRScanner
//
//  Created by 换一换 on 16/12/16.
//  Copyright © 2016年 换一换. All rights reserved.
//

#import "ViewController.h"
#import "ScanViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)start:(id)sender {
    ScanViewController *scan = [[ScanViewController alloc] init];
    [self.navigationController pushViewController:scan animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

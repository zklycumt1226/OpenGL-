//
//  ViewController.m
//  OpenGL三角形
//
//  Created by zkzk on 2018/9/11.
//  Copyright © 2018年 1707002. All rights reserved.
//

#import "ViewController.h"
#import "RenderView.h"

@interface ViewController ()

@property (nonatomic, strong) RenderView* renderView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.renderView = [[RenderView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:self.renderView];
    //self.renderView.backgroundColor = [UIColor blueColor];
}


@end

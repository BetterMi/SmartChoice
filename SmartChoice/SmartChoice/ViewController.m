//
//  ViewController.m
//  SmartChoice
//
//  Created by HM (hongmin@qiyoukeji.com) on 16/7/12.
//  Copyright © 2016年 HM. All rights reserved.
//

#define SmartChoiceURL      @"http://m.xuan001.com"

#import "ViewController.h"

#import "MBProgressHUD.h"

typedef NS_ENUM(NSInteger, AlertType) {
    AlertTypeFail,
    AlertTypeSuccess
};

@interface ViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *defaultWebView;
@property (assign, nonatomic) BOOL firstLoadSuccess;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadRequest];
}

#pragma mark - webview delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self showBlank:NO message:nil withFrame:CGRectZero];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.firstLoadSuccess = YES;
    [self showBlank:NO message:nil withFrame:CGRectZero];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self alert:@"加载失败!" alertType:AlertTypeFail];
    if (!self.firstLoadSuccess) {
        [self showBlank:YES message:@"点击屏幕重新加载" withFrame:self.view.frame];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - private

- (void)showWait:(NSString *)message {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = message;
    hud.labelFont = [UIFont boldSystemFontOfSize:12.0f];
    hud.yOffset = -20;
    hud.cornerRadius = 6.0f;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.removeFromSuperViewOnHide = YES;
    [self.view addSubview:hud];
    [self.view bringSubviewToFront:hud];
    [hud show:YES];
}

- (void)hideWait {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)alert:(NSString *)message alertType:(AlertType)alertType {
    [self alert:message alertType:alertType verticalOffsetCenter:-20.0f delay:1.25f completion:nil];
}

- (void)alert:(NSString *)message alertType:(AlertType)alertType verticalOffsetCenter:(CGFloat)offsetY delay:(CGFloat)delay completion:(dispatch_block_t)completion {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelFont = [UIFont boldSystemFontOfSize:12.0f];
    hud.detailsLabelText = message;
    hud.yOffset = offsetY;
    hud.cornerRadius = 6.0f;
    hud.removeFromSuperViewOnHide = YES;
    
    NSString *alertImageName = @"";
    if (alertType == AlertTypeFail) {
        alertImageName = @"http_alert_fail";
    } else if (alertType == AlertTypeSuccess) {
        alertImageName = @"http_alert_success";
    }
    
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:alertImageName]];
    hud.mode = MBProgressHUDModeCustomView;

    [self.view addSubview:hud];
    
    [hud show:YES];
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [hud hide:YES];
        if (completion) {
            completion();
        }
    });
}

- (void)showBlank:(BOOL)show message:(NSString *)message withFrame:(CGRect)frame {
    static const NSInteger BlankViewTag = 191919;
    static const NSInteger BlankLabelTag = 919191;
    if (show)
    {
        UIView *blankView = [[UIView alloc] initWithFrame:frame];
        blankView.tag = BlankViewTag;
        blankView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithIntegerRed:0xf5 green:0xf5 blue:0xf5];
        [self.view addSubview:blankView];
        [self.view bringSubviewToFront:blankView];
        
        UIButton *reloadButton = [[UIButton alloc] initWithFrame:blankView.bounds];
        [reloadButton addTarget:self action:@selector(loadRequest) forControlEvents:UIControlEventTouchUpInside];
        [blankView addSubview:reloadButton];
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, 20.0f)];
        messageLabel.center = self.view.center;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.tag = BlankLabelTag;
        messageLabel.font = [UIFont systemFontOfSize:15.0f];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.text = message;
        [blankView addSubview:messageLabel];
    } else {
        UIView *blankView = [self.view viewWithTag:BlankViewTag];
        [blankView removeFromSuperview];
        blankView = nil;
    }
}

- (void)loadRequest {
    NSURL *pathUrl = [NSURL URLWithString:SmartChoiceURL];
    NSURLRequest *fileUrlRequest = [NSURLRequest requestWithURL:pathUrl];
    [self.defaultWebView loadRequest:fileUrlRequest];
}

@end

//
//  UMSocialLoginViewController.m
//  SocialSDK
//
//  Created by yeahugo on 13-5-19.
//  Copyright (c) 2013年 Umeng. All rights reserved.
//

#import "UMSocialLoginViewController.h"
//#import "UMSocial.h"

@interface UMSocialLoginViewController ()

@end

@implementation UMSocialLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(BOOL)closeOauthWebViewController:(UINavigationController *)navigationCtroller socialControllerService:(UMSocialControllerService *)socialControllerService
//{
//    if ([UMSocialAccountManager isOauthWithPlatform:socialControllerService.currentSnsPlatformName]) {
//        [navigationCtroller popToRootViewControllerAnimated:YES];
//        return YES;
//    }
//    return NO;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _snsTableView.dataSource = self;
    _snsTableView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    _snsTableView.frame = CGRectMake(_snsTableView.frame.origin.x, _snsTableView.frame.origin.y, _snsTableView.frame.size.width, 450);
    [_snsTableView reloadData];
    
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int snsNum = 5;
    if ([[UMSocialSnsPlatformManager sharedInstance].allSnsPlatformDictionary valueForKey:UMShareToSina]) {
        snsNum ++;
    }
    if ([[UMSocialSnsPlatformManager sharedInstance].allSnsPlatformDictionary valueForKey:UMShareToWechatSession]) {
        snsNum ++;
    }
    if ([[UMSocialSnsPlatformManager sharedInstance].allSnsPlatformDictionary valueForKey:UMShareToFacebook]) {
        snsNum ++;
    }
    if ([[UMSocialSnsPlatformManager sharedInstance].allSnsPlatformDictionary valueForKey:UMShareToTwitter]) {
        snsNum ++;
    }
    return snsNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *UMSnsAccountCellIdentifier = @"UMSnsAccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UMSnsAccountCellIdentifier];
    
    NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
    UMSocialSnsPlatform *snsPlatform = nil;
    if (indexPath.row == 4) {
        snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    }
    else if (indexPath.row == 5) {
        snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    }
    else if(indexPath.row == 6){
        snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    }
    else if(indexPath.row == 7){
        snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToFacebook];
    }
    else if(indexPath.row == 8){
        snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToTwitter];
    }
    else {
        snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:[UMSocialSnsPlatformManager getSnsPlatformStringFromIndex:indexPath.row]];
    }
                       
    UMSocialAccountEntity *accountEnitity = [snsAccountDic valueForKey:snsPlatform.platformName];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:UMSnsAccountCellIdentifier] ;
    }
    
    UISwitch *oauthSwitch = nil;
    if ([cell viewWithTag:snsPlatform.shareToType]) {
        oauthSwitch = (UISwitch *)[cell viewWithTag:snsPlatform.shareToType];
    }
    else{
        oauthSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 10, 40, 20)];
        oauthSwitch.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        oauthSwitch.tag = snsPlatform.shareToType;
        [cell addSubview:oauthSwitch];
    }
    oauthSwitch.center = CGPointMake(_snsTableView.bounds.size.width - 40, oauthSwitch.center.y);
    
    [oauthSwitch addTarget:self action:@selector(onSwitchOauth:) forControlEvents:UIControlEventValueChanged];
    
    NSString *showUserName = nil;
    
    //这里判断是否授权
    if ([UMSocialAccountManager isOauthAndTokenNotExpired:snsPlatform.platformName]) {
        [oauthSwitch setOn:YES];
        //这里获取到每个授权账户的昵称
        showUserName = accountEnitity.userName;
    }
    else {
        [oauthSwitch setOn:NO animated:YES];
        showUserName = [NSString stringWithFormat:@"尚未授权"];
    }
    
    if ([showUserName isEqualToString:@""]) {
        cell.textLabel.text = @"已授权";
    }
    else{
        cell.textLabel.text = showUserName;
    }
    NSLog(@"%@",snsPlatform.smallImageName);
    cell.imageView.image = [UIImage imageNamed:snsPlatform.smallImageName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


-(void)onSwitchOauth:(UISwitch *)switcher
{
    _changeSwitcher = switcher;
    
    if (switcher.isOn == YES) {
        [switcher setOn:NO];
        
        //此处调用授权的方法,你可以把下面的platformName 替换成 UMShareToSina,UMShareToTencent等
        NSString *platformName = [UMSocialSnsPlatformManager getSnsPlatformString:switcher.tag];
        
        [UMSocialControllerService defaultControllerService].socialUIDelegate = self;
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//           获取微博用户名、uid、token、第三方的原始用户信息thirdPlatformUserProfile等
            if (response.responseCode == UMSResponseCodeSuccess) {
                NSDictionary *dict = [UMSocialAccountManager socialAccountDictionary];
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:platformName];
                NSLog(@"\nusername = %@,\n usid = %@,\n token = %@ iconUrl = %@,\n unionId = %@,\n thirdPlatformUserProfile = %@,\n thirdPlatformResponse = %@ \n, message = %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL, snsAccount.unionId, response.thirdPlatformUserProfile, response.thirdPlatformResponse, response.message);
            }
            //这里可以获取到腾讯微博openid,Qzone的token等
            /*
            if ([platformName isEqualToString:UMShareToTencent]) {
                [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToTencent completion:^(UMSocialResponseEntity *respose){
                    NSLog(@"get openid  response is %@",respose);
                }];
            }
             */
         [_snsTableView reloadData];
        });
        
    }
    else {
        UIActionSheet *unOauthActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"解除授权", nil];
        unOauthActionSheet.destructiveButtonIndex = 0;
        unOauthActionSheet.tag = switcher.tag;
        [unOauthActionSheet showInView:self.tabBarController.tabBar];
    }
}

#pragma UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *platformType = [UMSocialSnsPlatformManager getSnsPlatformString:actionSheet.tag];
        [[UMSocialDataService defaultDataService] requestUnOauthWithType:platformType completion:^(UMSocialResponseEntity *response) {
            NSLog(@"unOauth response is %@",response);
            [_snsTableView reloadData];
        }];
        return;
    }
    [_snsTableView reloadData];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _snsTableView.frame = CGRectMake(_snsTableView.frame.origin.x, _snsTableView.frame.origin.y, _snsTableView.frame.size.width, 270);
    [_snsTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

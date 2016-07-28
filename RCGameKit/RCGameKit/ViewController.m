//
//  ViewController.m
//  RCGameKit
//
//  Created by RongCheng on 16/7/28.
//  Copyright © 2016年 RongCheng. All rights reserved.
//

#import "ViewController.h"
#import <GameKit/GameKit.h>
/*
 
 * GameKit.framework：iOS7之前的蓝牙通讯框架，从iOS7开始过期，但是目前多数应用还是基于此框架。
 * 仅支持iOS设备，传输内容仅限于沙盒或者照片库中用户选择的文件，并且第一个框架只能在同一个应用之间进行传输（一个iOS设备安装应用A，另一个iOS设备上安装应用B是无法传输的）
 
 */


@interface ViewController ()<GKPeerPickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *image;

 /** 会话 */ /*<  注释建议使用文档注释  >*/
@property (nonatomic, strong) GKSession *session;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    #warning GameKit是已经废弃的方法，在蓝牙连接时不稳定，不推荐使用。推荐使用MultipeerConnectivity.framework，CoreBluetooth.framework 两个框架
}
- (IBAction)contentBtn:(id)sender {
    // 创建一个附近设备的搜索框
    GKPeerPickerController *ppc = [[GKPeerPickerController alloc] init];
    
    ppc.delegate = self;
   
    [ppc show];
}
- (IBAction)sendData:(id)sender {
   
    if (!self.image.image) return;
    
    
    NSError *error = nil;
    
    
    // GKSendDataReliable    可靠的传输方式特点:慢 不会丢包  GKSendDataUnReliable 不可靠的传输方式特点:快 可能会丢包
    [self.session sendDataToAllPeers:UIImageJPEGRepresentation(self.image.image, 0.1) withDataMode:GKSendDataReliable                                       error:&error];
    if (error) {
        NSLog(@"send error:%@", error.localizedDescription);
    }
}
- (IBAction)chooseImageClick:(id)sender {

    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        NSLog(@"相册去哪儿呢!");
       
        return;
    }
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
   
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    ipc.delegate = self;
   
    [self presentViewController:ipc animated:YES completion:nil];

}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
   
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"%s, line = %d, info= %@", __FUNCTION__, __LINE__, info);
    self.image.image = info[UIImagePickerControllerOriginalImage];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GKPeerPickerControllerDelegate

// 已经成功连接到某个设备,并且开启了连接会话
- (void)peerPickerController:(GKPeerPickerController *)picker // 搜索框
              didConnectPeer:(NSString *)peerID  // 连接的设备
                   toSession:(GKSession *)session // 连接会话:通过会话可以进行数据传输
{
    NSLog(@"%s, line = %d", __FUNCTION__, __LINE__);
    
    
    [picker dismiss];
    
    self.session = session;
    
    
    // 设置完接受者之后,接收数据会触发: SEL = -receiveData:fromPeer:inSession:context:
    [self.session setDataReceiveHandler:self withContext:nil];
}

#pragma mark - 蓝牙设备接收到数据时,就会调用
- (void)receiveData:(NSData *)data // 数据
           fromPeer:(NSString *)peer // 来自哪个设备
          inSession:(GKSession *)session // 连接会话
            context:(void *)context
{
    NSLog(@"%s, line = %d, data = %@, peer = %@, sessoing = %@", __FUNCTION__, __LINE__, data, peer, session);
        self.image.image = [UIImage imageWithData:data];
    // 将图片存入相册
    UIImageWriteToSavedPhotosAlbum(self.image.image, nil, nil, nil);
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

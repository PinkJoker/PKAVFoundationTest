//
//  AVFoundationViewController.m
//  testVideoFilter
//
//  Created by Lyman Li on 2020/3/8.
//  Copyright © 2020 Lyman Li. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Masonry.h>
#import <Photos/Photos.h>
#import <Toast.h>

#import "CustomVideoCompositing.h"
#import "CustomVideoCompositionInstruction.h"
#import "AVFoundationViewController.h"

#import "PKEditorController.h"
@interface AVFoundationViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;

@property (nonatomic, strong) NSString *exportPath;

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *exportButton;

@property (nonatomic, assign) BOOL isExporting;
@property(nonatomic,strong)PKEditorController *editorController;
@property(nonatomic,strong)NSMutableArray *clips;
@property(nonatomic,strong)NSMutableArray *clipsTimeRanges;
@end

@implementation AVFoundationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commonInit];
}

#pragma mark - Private

- (void)commonInit {
    [self setupUI];
    [self setupPlayer];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupPlayButton];
    [self setupExportButton];
}

- (void)setupPlayButton {
    self.playButton = [[UIButton alloc] init];
    [self.view addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.centerX.equalTo(self.view).multipliedBy(0.5);
        make.top.equalTo(self.view).offset(self.view.frame.size.width + 120);
    }];
    [self configButton:self.playButton];
    [self.playButton setTitle:@"播放" forState:UIControlStateNormal];
    [self.playButton setTitle:@"暂停" forState:UIControlStateSelected];
    [self.playButton addTarget:self
                        action:@selector(playAction:)
              forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupExportButton {
    self.exportButton = [[UIButton alloc] init];
    [self.view addSubview:self.exportButton];
    [self.exportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.centerX.equalTo(self.view).multipliedBy(1.5);
        make.top.equalTo(self.view).offset(self.view.frame.size.width + 120);
    }];
    [self configButton:self.exportButton];
    [self.exportButton setTitle:@"导出" forState:UIControlStateNormal];
    [self.exportButton addTarget:self
                          action:@selector(exportAction:)
                forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupPlayer {
    self.editorController = [[PKEditorController alloc]init];



    self.clips = [NSMutableArray array];
    self.clipsTimeRanges = [NSMutableArray array];
    AVURLAsset *asset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"db" ofType:@"mp4"]]];
    AVURLAsset *asset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"db1" ofType:@"MP4"]]];
//    AVURLAsset *asset3 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"asset4" ofType:@"mp4"]]];
    dispatch_group_t dispatchGroup = dispatch_group_create();
    NSArray *assetKeys = @[@"tracks",@"duration",@"composable"];
    [self.clips addObject:asset1];
    [self.clips addObject:asset2];
    [self loadAsset:asset1 withKeys:assetKeys usingDispatchGroup:dispatchGroup];
    [self loadAsset:asset2 withKeys:assetKeys usingDispatchGroup:dispatchGroup];
//    [self loadAsset:asset3 withKeys:assetKeys usingDispatchGroup:dispatchGroup];

    [self.clipsTimeRanges addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMake(0, 1), asset1.duration)]];
    [self.clipsTimeRanges addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMake(0, 1), CMTimeMake(6, 1))]];
//    [self.clipsTimeRanges addObject:[NSValue valueWithCMTimeRange:CMTimeRangeMake(CMTimeMake(3, 1), CMTimeMake(6, 1))]];
    self.editorController.clipsTimeRanges = self.clipsTimeRanges;
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
        [self synchronizeWithEditor];
    });
    
    
    
    
    
    
    // asset
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"db" withExtension:@"mp4"];
//    self.asset = [AVURLAsset assetWithURL:url];
//
//    // videoComposition
//    self.videoComposition = [self createVideoCompositionWithAsset:self.asset];
//    self.videoComposition.customVideoCompositorClass = [CustomVideoCompositing class];
//
//    // playerItem
//    self.playerItem = [[AVPlayerItem alloc] initWithAsset:self.asset];
//    self.playerItem.videoComposition = self.videoComposition;
//
//    // player
//    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
//
//    // playerLayer
//    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    self.playerLayer.frame = CGRectMake(0,
//                                        80,
//                                        self.view.frame.size.width,
//                                        self.view.frame.size.width);
//    [self.view.layer addSublayer:self.playerLayer];
}

-(void)loadAsset:(AVAsset *)asset withKeys:(NSArray *)assetKeys usingDispatchGroup:(dispatch_group_t)dispatchGroup
{
    dispatch_group_enter(dispatchGroup);
    [asset loadValuesAsynchronouslyForKeys:assetKeys completionHandler:^{
        for (NSString * key in assetKeys) {
            NSError *error;
            if([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed){
                goto bail;
            }else if ([asset statusOfValueForKey:key error:&error] == AVKeyValueStatusLoaded){
//                [self.clips addObject:asset];
                goto bail;
            }
        }
        if(![asset isComposable]){
            goto bail;
        }
  
     
        
    bail:
        dispatch_group_leave(dispatchGroup);
        
    }];
    
    
}
-(void)synchronizeWithEditor
{
    [self synchronizeEditorClipsWithOurClips];
    [self.editorController buildCompositionObjectsForPlayback:YES];
    self.playerItem = [self.editorController playerItem];
//    self.playerItem.videoComposition = self.editorController.videoComposition;
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer  = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    self.playerLayer.frame = CGRectMake(100, 200, 200, 200*1280/720);
    self.playerLayer.backgroundColor = [UIColor yellowColor].CGColor;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerLayer.opaque = NO;
    self.playerLayer.drawsAsynchronously = YES;
    [self.view.layer addSublayer:self.playerLayer];
//    [self.player play];
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([object isKindOfClass:[AVPlayerItem class]]){
        if([keyPath isEqualToString:@"status"]){
            switch (self.playerItem.status) {
                case AVPlayerItemStatusReadyToPlay:
                    [self.player play];
                    break;
                    
                default:
                    break;
            }
        }
    }
}
- (void)synchronizeEditorClipsWithOurClips
{
    NSMutableArray *validClips = [NSMutableArray arrayWithCapacity:2];
    for (AVURLAsset *asset in self.clips) {
        if (![asset isKindOfClass:[NSNull class]]) {
            [validClips addObject:asset];
        }
    }
    
    self.editorController.clips = validClips;
}



- (AVMutableVideoComposition *)createVideoCompositionWithAsset:(AVAsset *)asset {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:asset];
    NSArray *instructions = videoComposition.instructions;
    NSMutableArray *newInstructions = [NSMutableArray array];
    for (AVVideoCompositionInstruction *instruction in instructions) {
        NSArray *layerInstructions = instruction.layerInstructions;
        // TrackIDs
        NSMutableArray *trackIDs = [NSMutableArray array];
        for (AVVideoCompositionLayerInstruction *layerInstruction in layerInstructions) {
            [trackIDs addObject:@(layerInstruction.trackID)];
        }
        CustomVideoCompositionInstruction *newInstruction = [[CustomVideoCompositionInstruction alloc] initWithSourceTrackIDs:trackIDs timeRange:instruction.timeRange];
        newInstruction.layerInstructions = instruction.layerInstructions;
        [newInstructions addObject:newInstruction];
    }
    videoComposition.instructions = newInstructions;
    return videoComposition;
}

- (void)configButton:(UIButton *)button {
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.tintColor = [UIColor clearColor];
    [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [button setBackgroundColor:[UIColor blackColor]];
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
}

#pragma mark - Action

- (void)playAction:(UIButton *)button {
    if (self.isExporting) {
        return;
    }
    
    button.selected = !button.selected;
    if (button.selected) {
        [self.player play];
    } else {
        [self.player pause];
    }
}

- (void)exportAction:(UIButton *)button {
    if (self.isExporting) {
        return;
    }
    self.isExporting = YES;
    
    // 先暂停播放
    [self.player pause];
    self.playButton.selected = NO;
    
    [self.view makeToastActivity:CSToastPositionCenter];
 
    // 创建导出任务
    self.exportSession = [[AVAssetExportSession alloc] initWithAsset:self.asset presetName:AVAssetExportPresetHighestQuality];
    self.exportSession.videoComposition = self.videoComposition;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    
    NSString *fileName = [NSString stringWithFormat:@"%f.m4v", [[NSDate date] timeIntervalSince1970] * 1000];
    self.exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    self.exportSession.outputURL = [NSURL fileURLWithPath:self.exportPath];
    
    __weak typeof(self) weakself = self;
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        [weakself saveVideo:weakself.exportPath completion:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.view hideToastActivity];
                if (success) {
                    [weakself.view.window makeToast:@"保存成功"];
                } else {
                    [weakself.view.window makeToast:@"保存失败"];
                }
                weakself.isExporting = NO;
            });
        }];
    }];
}

#pragma mark - Private

// 保存视频到相册
- (void)saveVideo:(NSString *)path completion:(void (^)(BOOL success))completion {
    void (^saveBlock)(void) = ^ {
        NSURL *url = [NSURL fileURLWithPath:path];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (completion) {
                completion(success);
            }
        }];
    };
    
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if (authStatus == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                saveBlock();
            } else {
                if (completion) {
                    completion(NO);
                }
            }
        }];
    } else if (authStatus != PHAuthorizationStatusAuthorized) {
        if (completion) {
            completion(NO);
        }
    } else {
        saveBlock();
    }
}

@end

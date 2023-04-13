//
//  PKEditorController.h
//  PKVideoOveray
//
//  Created by Snow Joker on 2023/4/10.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreFoundation/CoreFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface PKEditorController : NSObject

@property(nonatomic,strong)NSArray *clips;
@property(nonatomic,strong)NSArray *clipsTimeRanges;

@property(nonatomic,strong)AVMutableComposition *composition;
@property(nonatomic,strong)AVMutableVideoComposition *videoComposition;

-(void)buildCompositionObjectsForPlayback:(BOOL)forPlayback;

-(AVAssetExportSession *)assetExportSessionWithPreset:(NSString *)presetName;

-(AVPlayerItem *)playerItem;
@end

NS_ASSUME_NONNULL_END

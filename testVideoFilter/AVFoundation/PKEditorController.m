//
//  PKEditorController.m
//  PKVideoOveray
//
//  Created by Snow Joker on 2023/4/10.
//

#import "PKEditorController.h"
#import "CustomVideoCompositionInstruction.h"
#import "CustomVideoCompositing.h"
@implementation PKEditorController


-(void)buildCompositionObjectsForPlayback:(BOOL)forPlayback
{
    if(_clips.count == 0){
        self.composition = nil;
        self.videoComposition = nil;
        return;
    }
    CGSize videoSize = [[_clips objectAtIndex:0]naturalSize];
    AVMutableComposition *composition = [AVMutableComposition composition];
    composition.naturalSize = videoSize;
    self.composition = [self buildComposition:composition];
    
    AVMutableVideoComposition *videoComposition  = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:self.composition];
    videoComposition.customVideoCompositorClass = [CustomVideoCompositing class];
    [self buildVideoComposition:videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.renderSize = videoSize;
    videoComposition.renderScale = 1.0;
    self.videoComposition = videoComposition;
    
    
}

-(AVMutableComposition *)buildComposition:(AVMutableComposition *)composition
{
    AVMutableCompositionTrack *compositionVideoTracks[2];
    AVMutableCompositionTrack *compositionAudioTracks[2];
    compositionVideoTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionVideoTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    compositionAudioTracks[0] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    compositionAudioTracks[1] = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime nextClipStartTime = kCMTimeZero;
    NSInteger i;
    NSUInteger clipsCount = [_clips count];
    // Add two video tracks and two audio tracks.

    for (i = 0; i < clipsCount; i++ ) {
        NSInteger alternatingIndex = i % 2; // alternating targets: 0, 1, 0, 1, ...
        AVURLAsset *asset = [_clips objectAtIndex:i];
        NSValue *clipTimeRange = [_clipsTimeRanges objectAtIndex:i];
        CMTimeRange timeRangeInAsset;
        if (clipTimeRange)
            timeRangeInAsset = [clipTimeRange CMTimeRangeValue];
        else
            timeRangeInAsset = CMTimeRangeMake(kCMTimeZero, [asset duration]);
        
            AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            [compositionVideoTracks[i] insertTimeRange:timeRangeInAsset ofTrack:clipVideoTrack atTime:kCMTimeZero error:nil];
        

        AVAssetTrack *clipAudioTrack;
        NSArray *array = [asset tracksWithMediaType:AVMediaTypeAudio];
        if (i == 0) {
            clipAudioTrack = [array objectAtIndex:0];
            [compositionAudioTracks[0] insertTimeRange:timeRangeInAsset ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
        }
    }
    
    return composition;
}


-(AVAssetExportSession *)assetExportSessionWithPreset:(NSString *)presetName
{
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:self.composition presetName:presetName];
    session.videoComposition = self.videoComposition;
    return session;
}

- (AVMutableVideoComposition *)buildVideoComposition:(AVMutableVideoComposition *)videoComposition
{
    NSMutableArray *instructions = [NSMutableArray array];
    for (AVVideoCompositionInstruction *instruction in videoComposition.instructions) {
        NSArray *layerInstructions = instruction.layerInstructions;
        // TrackIDs
        NSMutableArray *trackIDs = [NSMutableArray array];
        for (AVVideoCompositionLayerInstruction *layerInstruction in layerInstructions) {
            [trackIDs addObject:@(layerInstruction.trackID)];
        }
        CustomVideoCompositionInstruction *newInstruction = [[CustomVideoCompositionInstruction alloc] initWithSourceTrackIDs:trackIDs timeRange:instruction.timeRange];
        newInstruction.layerInstructions = instruction.layerInstructions;
        [instructions addObject:newInstruction];
    }
//    self.composition = composition;
    videoComposition.instructions = instructions;
    return  videoComposition;
}


-(AVPlayerItem *)playerItem
{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.composition];
    playerItem.videoComposition = self.videoComposition;
    return playerItem;
}



@end

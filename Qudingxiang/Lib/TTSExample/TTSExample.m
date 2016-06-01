//
//  TTSExample.m
//  voicedemo
//
//  Created by 陈波涛 on 16/5/6.
//  Copyright © 2016年 weixun. All rights reserved.
//

#import "TTSExample.h"
#import <AVFoundation/AVFoundation.h>


@interface TTSExample ()<AVSpeechSynthesizerDelegate>


@property (nonatomic, strong) AVSpeechSynthesizer *aVSpeechSynthesizer;

@end


@implementation TTSExample

- (instancetype)init{
    
    if (self = [super init]) {
        
        _aVSpeechSynthesizer.delegate = self;
        
    }
    
    return self;
}


- (void)read:(NSString *)str{
    
//    NSString * str = @"静夜思,李白,床前明月光,疑是地上霜,举头望明月,低头思故乡";
    
    AVSpeechUtterance * aVSpeechUtterance = [[AVSpeechUtterance alloc] initWithString:str];
    
    aVSpeechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate;
    
    aVSpeechUtterance.voice =[AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    
    [self.aVSpeechSynthesizer speakUtterance:aVSpeechUtterance];
    
}

- (void)stopRead{

    [self.aVSpeechSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
}


- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance;{

    NSLog(@"阅读完毕");

}

- (AVSpeechSynthesizer *)aVSpeechSynthesizer{
    
    if (!_aVSpeechSynthesizer) {
        
        
        _aVSpeechSynthesizer = [[AVSpeechSynthesizer alloc] init];
        
    }
    
    return _aVSpeechSynthesizer;
    
}


@end

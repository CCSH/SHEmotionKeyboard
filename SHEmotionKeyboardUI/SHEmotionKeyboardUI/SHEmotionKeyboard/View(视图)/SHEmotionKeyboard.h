//
//  SHEmotionKeyboard.h
//  SHEmotionKeyboardUI
//
//  Created by CSH on 2016/12/7.
//  Copyright © 2016年 CSH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Emoji.h"
#import "SHEmotionModel.h"

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

@protocol SHEmotionKeyboardDelegate <NSObject>
@optional
/**
 *  获取图片对应文字
 *
 *  @param text 文字
 */
- (void)emoticonInputDidTapText:(NSString *)text;

/**
 *  获取图片表情对应的url
 *
 *  @param url 图片路径
 */
- (void)emoticonImageDidTapUrl:(NSString *)url;

/**
 *  删除表情
 */
- (void)emoticonInputDidTapBackspace;
/**
 *  发送表情
 */
- (void)emoticonInputDidTapSend;

@end

@interface SHEmotionKeyboard : UIView

//代理
@property (nonatomic, weak) id<SHEmotionKeyboardDelegate> delegate;

//下方按钮集合(SHEmoticonType)
@property (nonatomic, strong) NSArray *toolBarArr;

+ (instancetype)sharedSHEmotionKeyboard;

@end

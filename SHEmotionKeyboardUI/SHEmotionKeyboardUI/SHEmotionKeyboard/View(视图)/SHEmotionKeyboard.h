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
 表情键盘内容点击

 @param text 文字
 @param url 网址
 @param path 路径
 @param type 类型
 */
- (void)emoticonInputWithText:(NSString *)text Url:(NSString *)url Path:(NSString *)path Type:(SHEmoticonType )type;

/**
 表情键盘删除点击
 */
- (void)emoticonInputDelete;

/**
 表情键盘发送点击
 */
- (void)emoticonInputSend;

@end

@interface SHEmotionKeyboard : UIView

//代理
@property (nonatomic, weak) id<SHEmotionKeyboardDelegate> delegate;

//下方按钮集合(SHEmoticonType)
@property (nonatomic, strong) NSArray *toolBarArr;

+ (instancetype)sharedSHEmotionKeyboard;

@end

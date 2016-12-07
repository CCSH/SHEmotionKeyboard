//
//  SHEmotionTool.h
//  SHEmotionKeyboardUI
//
//  Created by CSH on 2016/12/7.
//  Copyright © 2016年 CSH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SHEmotionModel.h"

/**
 表情键盘工具类
 */
@interface SHEmotionTool : NSObject

//通过表情的描述字符串找到对应表情模型
+ (SHEmotionModel *)emotionWithChs:(NSString *)chs;

//添加最近表情到最近表情列表(集合)
+ (void)addRecentEmotion:(SHEmotionModel *)emotion;
//添加图片到收藏
+ (void)addCollectImageWithUrl:(NSString *)url;
//删除收藏图片
+ (void)delectCollectImageWithUrl:(NSString *)url;
//获取other图片
+ (UIImage *)emotionImageWithName:(NSString *)name;


//获取最近表情列表
+ (NSArray *)recentEmotions;

//自定义表情
+ (NSArray *)customEmotions;

//系统表情
+ (NSArray *)systemEmotions;

//gif表情
+ (NSArray *)gifEmotions;

//收藏图片
+ (NSArray *)collectEmotions;

//匹配字符串
+ (NSMutableAttributedString *)dealTheMessageWithStr:(NSString *)str;

@end

//
//  SHEmotionTool.m
//  SHEmotionKeyboardUI
//
//  Created by CSH on 2016/12/7.
//  Copyright © 2016年 CSH. All rights reserved.
//

#import "SHEmotionTool.h"
#import "SHEmotionModel.h"

//最近表情数组
static NSMutableArray *_recentEmotions;
//收藏表情数组
static NSMutableArray *_collectImages;

@implementation SHEmotionTool

#pragma mark 初始化
+ (void)initialize{
    if (!_recentEmotions) {
        _recentEmotions = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:Recentemotions_PAHT]];
    }
    if (!_collectImages) {
        
        _collectImages = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:CollectImage_PAHT]];
    }
}

#pragma mark - 通过表情的描述字符串找到对应表情模型
+ (SHEmotionModel *)emotionWithChs:(NSString *)chs{
    
    //先遍历自定义表情
    NSArray *customEmotions = [self customEmotions];
    for (SHEmotionModel *emotion in customEmotions) {
        if ([emotion.chs isEqualToString:chs]) {
            return emotion;
        }
    }
    
    //没有的话遍历GIF表情
    NSArray *gifEmotions = [self gifEmotions];
    for (SHEmotionModel *emotion in gifEmotions) {
        if ([emotion.chs isEqualToString:chs]) {
            return emotion;
        }
    }
    return nil;
}

#pragma mark - 添加最近图片
+ (void)addRecentEmotion:(SHEmotionModel *)emotion{
    
    [_recentEmotions removeObject:emotion];
    [_recentEmotions insertObject:emotion atIndex:0];
    
    //3.保存
    [NSKeyedArchiver archiveRootObject:[_recentEmotions copy] toFile:Recentemotions_PAHT];
}

#pragma mark - 添加收藏图片
+ (void)addCollectImageWithUrl:(NSString *)url{
    
    NSString *path = CollectImage_imagepath;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES attributes:nil error:nil];
    }
    path = [path stringByAppendingPathComponent:url.lastPathComponent];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        BOOL result =[data writeToFile:path atomically:YES];
        if (result) {
            NSLog(@"添加收藏成功");
            dispatch_async(dispatch_get_main_queue(), ^{
                
                SHEmotionModel *model = [[SHEmotionModel alloc]init];
                model.code = [NSString stringWithFormat:@"[%@]",url.lastPathComponent];
                model.png = url.lastPathComponent;
                model.type = SHEmoticonType_collect;
                model.path = url;
                
                [_collectImages removeObject:model];
                [_collectImages insertObject:model atIndex:0];
                
                [NSKeyedArchiver archiveRootObject:[_collectImages copy] toFile:CollectImage_PAHT];
            });
        }else{
            NSLog(@"添加收藏失败");
        }
        
    });
}

#pragma mark - 删除收藏图片
+ (void)delectCollectImageWithModel:(SHEmotionModel *)model{
    
    [_collectImages removeObject:model];
    [NSKeyedArchiver archiveRootObject:[_collectImages copy] toFile:CollectImage_PAHT];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"delectCollectImage" object:nil];
    
}

#pragma mark - 获取plist路径下的数据
+ (NSArray *)loadResourceWithName:(NSString *)name{
    
    NSString *bundlePath = [[NSBundle mainBundle]pathForResource:@"SHEmotionKeyboard.bundle" ofType:nil];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *path = [bundle pathForResource:[NSString stringWithFormat:@"%@/info.plist",name] ofType:@""];
    
    NSArray *array = [NSArray arrayWithContentsOfFile:path];
    
    return array;
}

#pragma mark - 获取other图片
+ (UIImage *)emotionImageWithName:(NSString *)name{
    
    NSString *bundlePath = [[NSBundle mainBundle]pathForResource:@"SHEmotionKeyboard.bundle" ofType:nil];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSString *path = [bundle pathForResource:[NSString stringWithFormat:@"other/%@@2x.png",name] ofType:@""];
    
    return [UIImage imageWithContentsOfFile:path];
}

#pragma mark - 获取图片
#pragma mark 收藏图片
+ (NSArray *)collectEmotions{
    return _collectImages;
}

#pragma mark 最近图片
+ (NSArray *)recentEmotions{
    return _recentEmotions;
}

#pragma mark 自定义表情
+ (NSArray *)customEmotions{
    //读取默认表情
    NSArray *array = [self loadResourceWithName:@"custom_emoji"];
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for (NSDictionary *dict in array) {
        SHEmotionModel *model = [SHEmotionModel emotionWithDict:dict];
        model.type = SHEmoticonType_custom;
        [arrayM addObject:model];
    };
    //给集合里面每一个元素都执行某个方法
    [arrayM makeObjectsPerformSelector:@selector(setPath:) withObject:[NSString stringWithFormat:@"%@/custom_emoji/",[[NSBundle mainBundle] pathForResource:@"SHEmotionKeyboard" ofType:@"bundle"]]];
    
    return arrayM;
}

#pragma mark 系统表情
+ (NSArray *)systemEmotions{
    //读取emoji表情
    NSArray *array = [self loadResourceWithName:@"system_emoji"];
    
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for (NSDictionary *dict in array) {
        SHEmotionModel *model = [SHEmotionModel emotionWithDict:dict];
        model.type = SHEmoticonType_system;
        [arrayM addObject:model];
    }
    return arrayM;
}

#pragma mark GIF表情
+ (NSArray *)gifEmotions{
    //读取大表情
    NSArray *array = [self loadResourceWithName:@"gif_emoji"];
    
    NSMutableArray *arrayM = [NSMutableArray array];
    
    for (NSDictionary *dict in array) {
        SHEmotionModel *model = [SHEmotionModel emotionWithDict:dict];
        model.type = SHEmoticonType_gif;
        [arrayM addObject:model];
    }
    //给集合里面每一个元素都执行某个方法
    [arrayM makeObjectsPerformSelector:@selector(setPath:) withObject:[NSString stringWithFormat:@"%@/gif_emoji/",[[NSBundle mainBundle] pathForResource:@"SHEmotionKeyboard" ofType:@"bundle"]]];
    return arrayM;
}

#pragma mark 文字编辑
+ (NSMutableAttributedString *)dealTheMessageWithStr:(NSString *)str
{
    
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:str];
    
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, str.length)];
    
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:22] range:NSMakeRange(0, str.length)];
    //    \\[(emoji_\\d+?)\\]               [emoji_数字]
    //    \\[[\\u4e00-\\u9fa5|a-z|A-Z]+\\]     [文字]
    
    NSString * zhengze = @"\\[[\\u4e00-\\u9fa5|a-z|A-Z]+\\]";
    //正则表达式
    NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:zhengze options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray * arr = [re matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    
    //测试用的纸匹配自定义图片
//    NSArray *faceArr =  [SHEmotionTool customEmotions];
//    faceArr =  [SHEmotionTool gifEmotions];
    NSMutableArray *faceArr = [[NSMutableArray alloc] init];
    [faceArr addObjectsFromArray:[SHEmotionTool customEmotions]];
    [faceArr addObjectsFromArray:[SHEmotionTool gifEmotions]];
    [faceArr addObjectsFromArray:[SHEmotionTool collectEmotions]];
    
    //如果有多个表情图，必须从后往前替换，因为替换后Range就不准确了
    for (int j =(int) arr.count - 1; j >= 0; j--) {
        //NSTextCheckingResult里面包含range
        NSTextCheckingResult * result = arr[j];
        
        [faceArr enumerateObjectsUsingBlock:^(SHEmotionModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[str substringWithRange:result.range] isEqualToString:obj.code] || [[str substringWithRange:result.range] isEqualToString:obj.chs])//从数组中的字典中取元素
            {
                
                SHEmotionModel *model = [SHEmotionTool emotionWithChs:obj.chs];
                
                NSTextAttachment * textAttachment = [[NSTextAttachment alloc]init];//添加附件,图片
                
                textAttachment.image = [UIImage imageWithContentsOfFile:model.path];
                
                CGFloat height = [UIFont systemFontOfSize:22].lineHeight;
                textAttachment.bounds = CGRectMake(0, -2, height, height);
                
                NSAttributedString * imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                
                [attStr replaceCharactersInRange:result.range withAttributedString:imageStr];//替换未图片附件
                
                *stop = YES;
            }
        }];
        
    }
    return attStr;
}

@end

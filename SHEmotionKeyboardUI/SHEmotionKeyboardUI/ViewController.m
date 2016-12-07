//
//  ViewController.m
//  SHEmotionKeyboardUI
//
//  Created by CSH on 2016/12/7.
//  Copyright © 2016年 CSH. All rights reserved.
//

#import "ViewController.h"
#import "SHEmotionKeyboard.h"
#import "SHEmotionTool.h"

@interface ViewController ()<SHEmotionKeyboardDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *message;

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

//表情键盘
@property (nonatomic , strong) SHEmotionKeyboard *emotionKeyboard;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.messageTextView.delegate = self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {//点击了发送
        //发送文字
        self.message.attributedText =  [SHEmotionTool dealTheMessageWithStr:self.messageTextView.text];
        return NO;
    }
    return YES;
}

- (IBAction)btnClick:(id)sender {
    [self.view endEditing:YES];
    self.emotionKeyboard.hidden = !self.emotionKeyboard.hidden;
}

- (SHEmotionKeyboard *)emotionKeyboard{
    
    if (!_emotionKeyboard) {
        _emotionKeyboard = [SHEmotionKeyboard sharedSHEmotionKeyboard];
         _emotionKeyboard.frame = CGRectMake(0, self.view.frame.size.height - 216, self.view.frame.size.width, 216);
        _emotionKeyboard.toolBarArr = @[@"101",@"102",@"103",@"104"];
        _emotionKeyboard.hidden = YES;
        _emotionKeyboard.delegate = self;
        [self.view addSubview:_emotionKeyboard];
    }
    return _emotionKeyboard;
}

#pragma mark - SHEmotionKeyboardDelegate
#pragma mark 发送表情
- (void)emoticonInputDidTapSend
{
    //发送文字
     self.message.attributedText =  [SHEmotionTool dealTheMessageWithStr:self.messageTextView.text];
}

#pragma mark 获取表情对应字符
- (void)emoticonInputDidTapText:(NSString*)text
{
    [self.messageTextView insertText:text];
}

#pragma mark 删除表情
- (void)emoticonInputDidTapBackspace
{
    NSString* inputString;
    inputString = self.messageTextView.text;
    NSString* string = nil;
    NSInteger stringLength = inputString.length;
    
    if (stringLength > 0) {
        if (stringLength == 1 || stringLength == 2) { //只有1个或2个字符时
            if ([inputString isEmoji]) { //emoji
                string = @"";
            }
            else { //普通字符
                string = [inputString substringToIndex:stringLength - 1];
            }
        }
        else if ([@"]" isEqualToString:[inputString substringFromIndex:stringLength - 1]]) { //默认表情
            
            if ([inputString rangeOfString:@"["].location == NSNotFound) {
                string = [inputString substringToIndex:stringLength - 1];
            }
            else {
                string = [inputString substringToIndex:[inputString rangeOfString:@"[" options:NSBackwardsSearch].location];
            }
        }else if ([[inputString substringFromIndex:stringLength - 1] isEmoji] || [[inputString substringFromIndex:stringLength - 2] isEmoji]) { //末尾是emoji
            
            if ([[inputString substringFromIndex:stringLength - 2] isEmoji]) {
                string = [inputString substringToIndex:stringLength - 2];
            }
            else if ([[inputString substringFromIndex:stringLength - 1] isEmoji]) {
                string = [inputString substringToIndex:stringLength - 1];
            }
        }
        else { //是普通文字
            string = [inputString substringToIndex:stringLength - 1];
        }
    }
    [self.messageTextView setText:string];
}

/**
 *  获取图片表情对应的url
 *
 *  @param url <#url description#>
 */
- (void)emoticonImageDidTapUrl:(NSString*)url
{
    NSLog(@"%@", url);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

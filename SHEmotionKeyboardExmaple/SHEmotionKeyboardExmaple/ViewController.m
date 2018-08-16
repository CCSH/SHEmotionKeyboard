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

@interface ViewController ()<UITextViewDelegate>
    
@property (weak, nonatomic) IBOutlet UILabel *message;

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UITextField *imageTextFile;
@property (weak, nonatomic) IBOutlet UIWebView *otherMessage;

//表情键盘
@property (nonatomic , strong) SHEmotionKeyboard *emotionKeyboard;

@end

@implementation ViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.messageTextView.delegate = self;
    self.messageTextView.enablesReturnKeyAutomatically = YES;
    
    self.messageTextView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    self.imageTextFile.text = @"http://www.qqma.com/imgpic2/cpimagenew/2018/4/5/6e1de60ce43d4bf4b9671d7661024e7a.jpg";
}
    
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {//点击了发送
        //发送文字
        self.message.text =  [SHEmotionTool getRealStrWithAtt:self.messageTextView.attributedText];
        return NO;
    }
    return YES;
}
    
- (IBAction)btnClick:(id)sender {
    [self.view endEditing:YES];
    if (self.messageTextView.inputView) {
        self.messageTextView.inputView = nil;
    }else{
        self.messageTextView.inputView = self.emotionKeyboard;
    }
    [self.messageTextView reloadInputViews];
    
    [self.messageTextView becomeFirstResponder];
}
    
- (IBAction)addRecentClick:(id)sender {
    
    if ([self.imageTextFile.text rangeOfString:@"http"].location != NSNotFound) {
        self.imageTextFile.placeholder = @"请输入要收藏的图片网址";
        [SHEmotionTool addCollectImageWithUrl:self.imageTextFile.text];
    }else{
        self.imageTextFile.placeholder = @"别捣乱!!请输入要收藏的图片网址";
    }
    self.imageTextFile.text = nil;
    
}
    
- (SHEmotionKeyboard *)emotionKeyboard{
    
    if (!_emotionKeyboard) {
        _emotionKeyboard = [[SHEmotionKeyboard alloc]init];
        //配置表情键盘内容
        _emotionKeyboard.toolBarArr = @[@(SHEmoticonType_custom),
                                        @(SHEmoticonType_system),
                                        @(SHEmoticonType_gif),
                                        @(SHEmoticonType_collect),
                                        @(SHEmoticonType_recent)];
        
        //点击了发送
        _emotionKeyboard.sendEmotionBlock = ^{
            //发送文字
            self.message.text = [SHEmotionTool getRealStrWithAtt:self.messageTextView.attributedText];
        };
        
        //点击了删除
        _emotionKeyboard.deleteEmotionBlock = ^{
            [self.messageTextView deleteBackward];
        };
        
        //表请点击
        _emotionKeyboard.clickEmotionBlock = ^(SHEmotionModel *model) {
            switch (model.type) {
                case SHEmoticonType_collect://收藏(可用Url、也可以用路径)
                {
                    NSData *data = [NSData dataWithContentsOfFile:model.path];
                    [self.otherMessage loadData:data MIMEType:@"image/gif" textEncodingName:@"" baseURL:[NSURL new]];
                }
                    break;
                case SHEmoticonType_gif://Gif(默认路径为静态的)
                {
                    NSData *data = [NSData dataWithContentsOfFile:[kGif_Emoji_Path stringByAppendingString:model.gif]];
                    [self.otherMessage loadData:data MIMEType:@"image/gif" textEncodingName:@"" baseURL:[NSURL new]];
                }
                    break;
                default:
                {
                    //添加到输入框
                    NSInteger selectIndex = self.messageTextView.selectedRange.location;
                    
                    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithAttributedString:self.messageTextView.attributedText];
                    
                    NSAttributedString *att = [SHEmotionTool getAttWithEmotion:model];
                    //插入表情到光标位置
                    [attr insertAttributedString:att atIndex:selectIndex];
                    //设置字体
                    [attr addAttribute:NSFontAttributeName value:self.messageTextView.font range:NSMakeRange(0, attr.length)];
                    //放到文本框
                    self.messageTextView.attributedText = attr;
                    //移动光标位置
                    self.messageTextView.selectedRange = NSMakeRange(selectIndex + att.length,0);
                }
                    break;
            }
        };
        

        [_emotionKeyboard reloadView];
    }
    return _emotionKeyboard;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
    

@end

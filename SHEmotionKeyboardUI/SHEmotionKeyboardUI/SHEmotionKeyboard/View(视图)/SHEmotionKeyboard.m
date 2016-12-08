//
//  SHEmotionKeyboard.m
//  SHEmotionKeyboardUI
//
//  Created by CSH on 2016/12/7.
//  Copyright © 2016年 CSH. All rights reserved.
//

#import "SHEmotionKeyboard.h"
#import "UIView+Extension.h"
#import "SHEmotionModel.h"
#import "UIButton+RemoveHighlightEffect.h"
#import "SHEmotionTool.h"

#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

#pragma mark - 表情按钮SHEmotionButton
@class SHEmotionModel;

@interface SHEmotionButton : UIButton

//当前button显示的emotion
@property (nonatomic, strong) SHEmotionModel *emotion;
//其他
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIButton *deleteButton;

@end

@implementation SHEmotionButton

#pragma mark - 懒加载
- (UIButton *)deleteButton{
    if (!_deleteButton) {
        //删除按钮（收藏用）
        _deleteButton = [[UIButton alloc] init];
        
        //设置图片
        [_deleteButton setImage:[SHEmotionTool emotionImageWithName:@"compose_photo_close"] forState:UIControlStateNormal];
        //设置大小
        _deleteButton.size = [_deleteButton currentImage].size;
        
        _deleteButton.hidden = YES;
        
        [_deleteButton addTarget:self action:@selector(deleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self addSubview:_deleteButton];
    }
    return _deleteButton;
}

#pragma mark - 收藏删除点击
- (void)deleteBtnClick:(UIButton *)button{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 0.0;
        [SHEmotionTool delectCollectImageWithModel:self.emotion];
    } completion:^(BOOL finished) {
        //动画执行完毕,移除
        [self removeFromSuperview];
        
    }];
}

- (void)setEmotion:(SHEmotionModel *)emotion{
    _emotion = emotion;
    
    //设置按钮内容
    switch (emotion.type) {
        case SHEmoticonType_gif://GIF
        case SHEmoticonType_custom://自定义
        {
            //设置表情图片
            UIImage *image = [UIImage imageWithContentsOfFile:emotion.path];
            [self setImage:image forState:UIControlStateNormal];
        }
            break;
        case SHEmoticonType_system://系统
        {
            [self setTitle:[emotion.code emoji] forState:UIControlStateNormal];
        }
            break;
        case SHEmoticonType_collect://收藏
        {
            //拼接图片路径
            NSString *path = CollectImage_imagepath;
            
            path = [path stringByAppendingPathComponent:self.emotion.path.lastPathComponent];
            
            //设置图片
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            
            [self setImage:image forState:UIControlStateNormal];
            //设置内距
            [self setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            //添加长按手势
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTap:)];
            longPress.minimumPressDuration = 0.5;//最小点按时间
            [self addGestureRecognizer:longPress];


        }
            
            break;
        default:
            break;
    }

}

- (void)setImage:(UIImage *)image{
    _image = image;
    [self setImage:image forState:UIControlStateNormal];
}

#pragma mark - 长按收藏图片
-(void)longTap:(UILongPressGestureRecognizer *)longRecognizer
{
    //控制连续点击
    if (longRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按收藏图片");
        self.deleteButton.hidden = NO;
    }
}

@end

#pragma mark - 工具栏SHEmotionToolBar
@class SHEmotionToolBar;

@protocol SHEmotionToolBarDelegate <NSObject>
- (void)emotionToolbar:(SHEmotionToolBar *)toolBar buttonClickWithType:(SHEmoticonType)type;

@end

@interface SHEmotionToolBar : UIView

@property (nonatomic, weak) id<SHEmotionToolBarDelegate> delegate;
/**
 *  是否为默认键盘,默认只有默认表情和emoji,聊吧和消息界面有魔法和收藏
 */
@property (nonatomic, assign, getter=isDefault) BOOL Default;

@end

@interface SHEmotionToolBar()

//当前选中的button
@property (nonatomic, weak) UIButton *currentBtn;
//自定义按钮
@property (nonatomic, weak) UIButton *customBtn;
//系统按钮
@property (nonatomic, weak) UIButton *systemBtn;
//gif按钮
@property (nonatomic, weak) UIButton *gifBtn;
//收藏按钮
@property (nonatomic, weak) UIButton *collectBtn;
//最近按钮
@property (nonatomic, weak) UIButton *recentBtn;

@end

@implementation SHEmotionToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置
        [self setup];
    }
    return self;
}
#pragma mark - 设置
- (void)setup{
    
    //设置背景
    self.backgroundColor = [UIColor whiteColor];
    
    SHEmotionKeyboard *emotionKeyboard = [SHEmotionKeyboard sharedSHEmotionKeyboard];

    [emotionKeyboard.toolBarArr enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        switch ([obj integerValue]) {
            case SHEmoticonType_collect://收藏
                self.collectBtn = [self addChildBtnWithTitle:@"收藏" bgImageName:@"mid" type:SHEmoticonType_collect];
                break;
            case SHEmoticonType_custom://自定义
                self.systemBtn = [self addChildBtnWithTitle:@"默认" bgImageName:@"mid" type:SHEmoticonType_custom];
                break;
            case SHEmoticonType_system://系统
                self.systemBtn = [self addChildBtnWithTitle:@"系统" bgImageName:@"mid" type:SHEmoticonType_system];
                break;
            case SHEmoticonType_gif://GIF
                self.gifBtn = [self addChildBtnWithTitle:@"GIF" bgImageName:@"mid" type:SHEmoticonType_gif];
                break;
            case SHEmoticonType_recent://最近
                self.recentBtn = [self addChildBtnWithTitle:@"最近" bgImageName:@"mid" type:SHEmoticonType_recent];
                break;
        }
        
    }];
    
    //设置发送按钮
    UIButton *sendBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.width / 5 * 4, 0, self.width / 5, self.height)];
    sendBtn.tag = 100;
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:[UIColor orangeColor]];
    [sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendBtn];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scrollviewLastPage:) name:@"scrollviewLastPage" object:nil];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //计算出每一个按钮的宽度
    CGFloat childW = self.width / 5;
    
    NSInteger count = self.subviews.count;
    
    
    for (int i=0; i<count; i++) {
        UIView *childView = self.subviews[i];
        
        //设置宽高大小位置
        childView.x = i * childW;
        
        if (childView.tag == 100) {
            childView.x = 4 * childW;
        }
        childView.width = childW;
        childView.height = self.height;
    }
}

- (UIButton *)addChildBtnWithTitle:(NSString *)title bgImageName:(NSString *)bgImageName type:(SHEmoticonType)type{
    
    UIButton *button = [[UIButton alloc] init];
    //去掉button的按下高亮效果
    //    button.removeHighlightEffect = YES;
    //设置标题
    [button setTitle:title forState:UIControlStateNormal];
    
    button.tag = type;

    //设置下方工具栏按钮颜色
    [button setBackgroundColor:[UIColor whiteColor]];

    [button setBackgroundImage:[SHEmotionTool emotionImageWithName:@"emoticon_keyboard_background"] forState:UIControlStateDisabled];
    
    //设置选中状态字体颜色
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    //设置未选中状态字体颜色
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    //监听点击事件
    [button addTarget:self action:@selector(childButtonClick:) forControlEvents:UIControlEventTouchDown];
    
    [self addSubview:button];
    
    
    return button;
}

- (void)setDelegate:(id<SHEmotionToolBarDelegate>)delegate{
    _delegate = delegate;
    SHEmotionKeyboard *emotionKeyboard = [SHEmotionKeyboard sharedSHEmotionKeyboard];
    if (emotionKeyboard.toolBarArr.count) {
        //默认点击第一个
        [self childButtonClick:(UIButton *)[self viewWithTag:[emotionKeyboard.toolBarArr[0] integerValue]]];
    }
}

#pragma mark - scroll滑动最后一页
- (void)scrollviewLastPage:(NSNotification *)notify{
    SHEmotionKeyboard *emotionKeyboard = [SHEmotionKeyboard sharedSHEmotionKeyboard];
    //为数组最后一个
    if ([notify.object intValue] == [[emotionKeyboard.toolBarArr lastObject] integerValue]) {
        //默认点击第一个
        [self childButtonClick:(UIButton *)[self viewWithTag:[emotionKeyboard.toolBarArr[0] integerValue]]];
    }

    [self childButtonClick:(UIButton *)[self viewWithTag:[notify.object intValue]]];
}


- (void)childButtonClick:(UIButton *)button{
    
    //先移除之前选中的button
    self.currentBtn.enabled = YES;
    //选中当前
    button.enabled = NO;
    //记录当前选中的按钮
    self.currentBtn = button;
    
    if ([self.delegate respondsToSelector:@selector(emotionToolbar:buttonClickWithType:)]) {
        [self.delegate emotionToolbar:nil buttonClickWithType:button.tag];
    }
}

- (void)sendBtnClick:(UIButton *)btn{
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EmotionSendBtnSelectedNoti" object:nil];
}

@end

#pragma mark - 滚动视图SHEmotionPageView

@interface SHEmotionPageView : UIView
/**
 *  当前一页对应的表情集合
 */
@property (nonatomic, strong) NSArray *emotions;

@end

#define MARGIN 10

@interface SHEmotionPageView()

//表情删除按钮
@property (nonatomic, strong) UIButton *deleteButton;

//表情按钮对应的集合,记录表情按钮,以便在调整位置的时候用到
@property (nonatomic, strong) NSMutableArray *emotionButtons;



@end

@implementation SHEmotionPageView{
    NSInteger  _page_max_col;
    NSInteger  _page_max_row;
}

- (UIButton *)deleteButton{
    if (!_deleteButton) {
        //表情删除按钮
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //设置不同状态的图片
        [_deleteButton setImage:[SHEmotionTool emotionImageWithName:@"compose_emotion_delete_highlighted"] forState:UIControlStateHighlighted];
        
        [_deleteButton setImage:[SHEmotionTool emotionImageWithName:@"compose_emotion_delete"] forState:UIControlStateNormal];
        //添加删除按钮点击事件
        [_deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_deleteButton];
    }
    return _deleteButton;
}


- (NSMutableArray *)emotionButtons{
    if (!_emotionButtons) {
        _emotionButtons = [NSMutableArray array];
    }
    return _emotionButtons;
}


- (void)setEmotions:(NSArray *)emotions{
    _emotions = emotions;
    
    SHEmotionModel *model = emotions[0];
    
    if (model.type == SHEmoticonType_gif) {
        _page_max_col = 4;
        _page_max_row = 2;
        [self.deleteButton removeFromSuperview];
    }else{
        _page_max_col = 7;
        _page_max_row = 3;
    }

    
    [emotions enumerateObjectsUsingBlock:^(SHEmotionModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SHEmotionButton *button = [[SHEmotionButton alloc] init];

        button.titleLabel.font = [UIFont systemFontOfSize:35];
        button.emotion = obj;
    
        //按钮点击监听
        [button addTarget:self action:@selector(emotionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        
        [self.emotionButtons addObject:button];
        
    }];
    
}



/**
 *  删除按钮点击
 *
 *  @param button <#button description#>
 */
- (void)deleteButtonClick:(UIButton *)button{
    
    //发送一个删除按钮点击的通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EmotionDeleteBtnSelectedNoti" object:nil];
}

/**
 *  表情点击
 *
 *  @param button <#button description#>
 */
- (void)emotionButtonClick:(SHEmotionButton *)button{
    
    //发出表情点击了的通知
    [[NSNotificationCenter defaultCenter]postNotificationName:@"EmotionDidSelectedNoti" object:button];
}

- (void)layoutSubviews{
    [super layoutSubviews];

    
    //取出子控件的个数
    NSInteger count = self.emotionButtons.count;
    
    
    CGFloat childW = (self.width - MARGIN * 2) / _page_max_col;
    CGFloat childH = (self.height - MARGIN) / _page_max_row;
    
    
    for (int i=0; i<count; i++) {
        UIView *view = self.emotionButtons[i];
        
        view.size = CGSizeMake(childW, childH);
        
        //求出当前在第几列第几行
        NSInteger col = i % _page_max_col;
        NSInteger row = i / _page_max_col;
        
        //设置位置
        view.x = col * childW + MARGIN;
        view.y = row * childH + MARGIN;
    }
    
    self.deleteButton.size = CGSizeMake(childW - 8, childH - 8);
    
    self.deleteButton.x = self.width - childW - MARGIN + 4;
    self.deleteButton.y = self.height - childH + 4;
    
    
}
@end

#pragma mark - 列表SHEmotionListView

@interface SHEmotionListView : UIView
/**
 *  当前ListView对应的表情集合
 */
@property (nonatomic, strong) NSArray *emotions;

@property (nonatomic, assign) SHEmoticonType currentType;

@end

@interface SHEmotionListView()<UIScrollViewDelegate>

//page
@property (nonatomic, weak) UIPageControl *pageControl;
//滚动视图
@property (nonatomic, weak) UIScrollView *scrollView;

//记录scrollView的用户自己添加的子控件,因为直接调用 scrollView.subViews会出现问题(因为滚动条也算scrollView的子控件)
@property (nonatomic, strong) NSMutableArray *scrollsubViews;


@end

@implementation SHEmotionListView

#pragma mark - 懒加载
- (NSMutableArray *)scrollsubViews{
    if (!_scrollsubViews) {
        _scrollsubViews = [NSMutableArray array];
    }
    return _scrollsubViews;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
    
        //添加scrollView
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        //隐藏水平方向的滚动条
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false;
        //开启分页
        scrollView.pagingEnabled = YES;
        
        //设置代理
        scrollView.delegate = self;
        
        [self addSubview:scrollView];
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        //添加uipageControl
        UIPageControl *control = [[UIPageControl alloc] init];
        
        [control setCurrentPageIndicatorTintColor:RGB(134, 134, 134)];
        [control setPageIndicatorTintColor:RGB(180, 180, 180)];
        
        [self addSubview:control];
        _pageControl = control;
    }
    return _pageControl;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    //设置pageControl
    self.pageControl.width = self.width;
    self.pageControl.height = 30;
    
    self.pageControl.y = self.height - self.pageControl.height;
    
    
    //设置scrollView
    self.scrollView.width = self.width;
    self.scrollView.height = self.pageControl.y;
    
    
    //设置scrollView里面子控件的大小
    
    for (int i=0; i<self.scrollsubViews.count; i++) {
        UIView *view = self.scrollsubViews[i];
        
        view.size = self.scrollView.size;
        view.x = i * self.scrollView.width;
    }
    
    //根据添加的子控件的个数计算内容大小
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width * self.scrollsubViews.count, self.scrollView.height);
}

- (void)setEmotions:(NSArray *)emotions{
    _emotions = emotions;
    
    [self.scrollView scrollsToTop];
    
    //在第二次执行这个方法的时候,就需要把之前已经添加的pageView给移除
    [self.scrollsubViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollsubViews removeAllObjects];
    
    
    //计算一页最多多少个
    NSInteger pageMaxEmotionCount = (self.currentType == SHEmoticonType_gif)?8:20;
    //根据个数计算出多少页
    
    
    //(总数+每一页的个数-1)/每一页的个数
    NSInteger page = (emotions.count + pageMaxEmotionCount - 1 )/ pageMaxEmotionCount ;
    
    
    //设置页数
    self.pageControl.numberOfPages = page;
    
    for (int i=0; i<page; i++) {
        
        SHEmotionPageView *view = [[SHEmotionPageView alloc] init];
        //切割每一页的表情集合
        NSRange range;
        
        range.location = i * pageMaxEmotionCount;
        range.length = pageMaxEmotionCount;
        
        //如果表情只有99个,那么最后一页就不满20个,所以需要加一个判断
        NSInteger lastPageCount = emotions.count - range.location;
        if (lastPageCount < pageMaxEmotionCount) {
            range.length = lastPageCount;
        }
        
        
        //截取出来是每一页对应的表情
        NSArray *childEmotions = [emotions subarrayWithRange:range];
        //设置每一页的表情集合
        view.emotions = childEmotions;
        
        [self.scrollView addSubview:view];
        [self.scrollsubViews addObject:view];
    }
    
    //告诉当前控件,去重新布局一下
    [self setNeedsLayout];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //计算页数-->小数-->四舍五入
    CGFloat page = scrollView.contentOffset.x / scrollView.width;
    self.pageControl.currentPage = (int)(page + 0.5);
    
    if (scrollView.contentSize.width < scrollView.contentOffset.x + scrollView.width) {
        SHEmotionKeyboard *emotionKeyboard = [SHEmotionKeyboard sharedSHEmotionKeyboard];
        if (_currentType == [[emotionKeyboard.toolBarArr lastObject] integerValue]) {
            _currentType = 100;
        }
        [scrollView scrollRectToVisible:CGRectMake(0, 0, scrollView.width, scrollView.height) animated:NO];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"scrollviewLastPage" object:[NSString stringWithFormat:@"%lu", _currentType + 1]];
    }
}

@end

#pragma mark - SHEmotionKeyboard

@interface SHEmotionKeyboard()<SHEmotionToolBarDelegate>

//下方工具栏
@property (nonatomic, weak) SHEmotionToolBar *toolBar;

//当前
@property (nonatomic, weak) SHEmotionListView *currentListView;

//收藏
@property (nonatomic, strong) SHEmotionListView *collectListView;

//自定义
@property (nonatomic, strong) SHEmotionListView *customListView;

//系统
@property (nonatomic, strong) SHEmotionListView *systemListView;

//GIF
@property (nonatomic, strong) SHEmotionListView *gifListView;

//最近
@property (nonatomic, strong) SHEmotionListView *recentListView;

@end

@implementation SHEmotionKeyboard


+ (instancetype)sharedSHEmotionKeyboard{
    static SHEmotionKeyboard *view;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!view) {
            view = [[self alloc]init];
            //设置
            [view setup];
        }
    });
    return view;
}


#pragma mark - 设置
- (void)setup{
    
    //设置颜色
    self.backgroundColor = RGB(243, 243, 247);
    
    //接收表情点击通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDidSelected:) name:@"EmotionDidSelectedNoti" object:nil];
    
    //删除按钮点击通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDeleteBtnSelected) name:@"EmotionDeleteBtnSelectedNoti" object:nil];
    //发送按钮点击
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(emotionSendBtnSelected) name:@"EmotionSendBtnSelectedNoti" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(delectCollectImage) name:@"delectCollectImage" object:nil];
}

- (void)setToolBarArr:(NSArray *)toolBarArr{
    
    _toolBarArr = toolBarArr;
    
    //分割线
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.height - self.toolBar.height, self.width , 0.6)];
    line.backgroundColor = RGB(225, 225, 225);
    
    [self addSubview:line];
}


#pragma mark 懒加载
- (SHEmotionToolBar *)toolBar{
    if (!_toolBar) {
        //设置下方工具栏
        SHEmotionToolBar *toolBar = [[SHEmotionToolBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 37)];
        toolBar.delegate = self;
        [self addSubview:toolBar];
        _toolBar = toolBar;
    }
    return _toolBar;
}

- (SHEmotionListView *)collectListView{
    if (!_collectListView) {
        _collectListView = [[SHEmotionListView alloc] init];
        _collectListView.currentType = SHEmoticonType_collect;
    }
    _collectListView.emotions = [SHEmotionTool collectEmotions];
    return _collectListView;
}

- (SHEmotionListView *)customListView{
    if (!_customListView) {
        _customListView = [[SHEmotionListView alloc] init];
        _customListView.currentType = SHEmoticonType_custom;
        _customListView.emotions = [SHEmotionTool customEmotions];
    }
    return _customListView;
}

- (SHEmotionListView *)systemListView{
    if (!_systemListView) {
        _systemListView = [[SHEmotionListView alloc] init];
        _systemListView.currentType = SHEmoticonType_system;
        _systemListView.emotions = [SHEmotionTool systemEmotions];
    }
    return _systemListView;
}

- (SHEmotionListView *)gifListView{
    if (!_gifListView) {
        _gifListView = [[SHEmotionListView alloc]init];
        _gifListView.currentType = SHEmoticonType_gif;
        _gifListView.emotions = [SHEmotionTool gifEmotions];
    }
    return _gifListView;
}

- (SHEmotionListView *)recentListView{
    if (!_recentListView) {
        _recentListView = [[SHEmotionListView alloc]init];
        _recentListView.currentType = SHEmoticonType_recent;
    }
    _recentListView.emotions = [SHEmotionTool recentEmotions];
    return _recentListView;
}

#pragma mark - EmotionKeyboard代理方法
#pragma mark 表情选中
- (void)emotionDidSelected:(NSNotification *)noti{
    SHEmotionButton *button = noti.object;
    NSString *text = nil;
    
    
    switch (button.emotion.type) {
        case SHEmoticonType_system://系统
            text = button.titleLabel.text;
            break;
        case SHEmoticonType_collect://收藏
            text = button.emotion.code;
            break;
        default:
            text = button.emotion.chs;
            break;
    }
    
    [SHEmotionTool addRecentEmotion:button.emotion];

    if ([_delegate respondsToSelector:@selector(emoticonInputWithText:Url:Path:Type:)]) {
        if (button.emotion.type == SHEmoticonType_collect) {//收藏
            NSString *path = CollectImage_imagepath;
            path = [path stringByAppendingPathComponent:button.emotion.path.lastPathComponent];
            [_delegate emoticonInputWithText:text Url:button.emotion.path Path:path Type:button.emotion.type];
        }else{
            [_delegate emoticonInputWithText:text Url:nil Path:button.emotion.path Type:button.emotion.type];
        }
    }

    
}

#pragma mark - 删除按钮点击
- (void)emotionDeleteBtnSelected{
    
    if ([self.delegate respondsToSelector:@selector(emoticonInputDelete)]) {
        [[UIDevice currentDevice] playInputClick];
        [self.delegate emoticonInputDelete];
    }
}

#pragma mark - 发送按钮点击
- (void)emotionSendBtnSelected{
    
    if ([self.delegate respondsToSelector:@selector(emoticonInputSend)]) {
        [[UIDevice currentDevice] playInputClick];
        [self.delegate emoticonInputSend];
    }
}

- (void)delectCollectImage{
    
    [self emotionToolbar:nil buttonClickWithType:SHEmoticonType_collect];
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    //设置toolBar宽度与y
    self.toolBar.y = self.height - self.toolBar.height;
    self.toolBar.width = self.width;
    
    //调整当前要显示的listView的位置与大小
    self.currentListView.width = self.width;
    self.currentListView.height = self.toolBar.y;
    
}



#pragma mark - EmotionToolBar delegate 方法
- (void)emotionToolbar:(SHEmotionToolBar *)toolBar buttonClickWithType:(SHEmoticonType)type{
    
    //先移除原来显示的
    [self.currentListView removeFromSuperview];
    
    switch (type) {
        case SHEmoticonType_collect://收藏
            [self addSubview:self.collectListView];
            break;
        case SHEmoticonType_custom://自定义
            [self addSubview:self.customListView];
            break;
        case SHEmoticonType_system://系统
            [self addSubview:self.systemListView];
            break;
        case SHEmoticonType_gif://GIF
            [self addSubview:self.gifListView];
            break;
        case SHEmoticonType_recent://最近
            [self addSubview:self.recentListView];
            
            break;
    }

    //再赋值当前显示的listView
    self.currentListView = [self.subviews lastObject];
}


- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end

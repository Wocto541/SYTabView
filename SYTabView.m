//
//  SYTabView.m
//  ZhuangheTourist
//
//  Created by ZhongJingHeTian on 2018/10/24.
//  Copyright © 2018年 wangshiyue. All rights reserved.
//

#define LINE_HEIGHT     2

#import "SYTabView.h"

@implementation SYTabViewModel

+ (instancetype)tabTitle:(NSString *)title
{
    return [self tabTitle:title value:nil];
}

+ (instancetype)tabTitle:(NSString *)title value:(id)value
{
    SYTabViewModel *model = [[SYTabViewModel alloc] init];
    model.title = title;
    model.value = value;
    return model;
}

@end



@interface SYTabView()

/**
 按钮数组
 */
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttonArray;

/**
 按钮滑动视图
 */
@property (nonatomic, weak) UIScrollView *tabScrollView;

/**
 选中线
 */
@property (nonatomic, weak) UIView *selectLine;

@end

@implementation SYTabView

#pragma mark - 页面绘制
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.clipsToBounds = YES;
        [self initTabView];
    }
    return self;
}

- (void)initTabView
{
    _normalFont = [UIFont systemFontOfSize:15];
    _normalColor = [UIColor blackColor];
    _selectedFont = [UIFont systemFontOfSize:15];
    _selectedColor = [UIColor blackColor];
    
    _selectLineColor = [UIColor zj_commonHighLightColor];
    _selectLineWidth = 60;
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1)];
    bottomLine.backgroundColor = [UIColor zj_colorWithHexString:@"#EAEAEA"];
    [self addSubview:bottomLine];
    _bottomLine = bottomLine;
    bottomLine.hidden = YES;
    
    
    UIScrollView *tabScrollView = [[UIScrollView alloc] init];
    [self addSubview:tabScrollView];
    _tabScrollView = tabScrollView;
    
    UIView *selectLine = [[UIView alloc] initWithFrame:CGRectMake(0, -LINE_HEIGHT, _selectLineWidth, LINE_HEIGHT)];
    [tabScrollView addSubview:selectLine];
    selectLine.backgroundColor = _selectLineColor;
    _selectLine = selectLine;
}

- (void)layoutSubviews
{
    NSLog(@"layoutSubviews");
    self.bottomLine.frame = CGRectMake(0, self.bounds.size.height - 1, self.bounds.size.width, 1);
    self.tabScrollView.frame = self.bounds;
    [self refreshTabView];
}

#pragma mark - 页面刷新
- (void)refreshTabView
{
    // 清除按钮
    for (UIView *view in self.tabScrollView.subviews)
    {
        if (view != self.selectLine)
        {
            [view removeFromSuperview];
        }
    }
    [self.buttonArray removeAllObjects];
    
    // 绘制按钮
    if (self.tabArray.count == 0)
    {
        self.selectLine.hidden = YES;
        self.tabScrollView.contentSize = CGSizeZero;
    }
    else
    {
        if (_selectIndex >= self.tabArray.count)
        {
            _selectIndex = 0;
        }
        
        self.selectLine.hidden = NO;
        
        CGFloat lastX = 0;
        CGFloat buttonW = 0;
        CGFloat buttonH = self.tabScrollView.bounds.size.height;
        
        if (!self.isAutoWidth)
        {
            if (self.showCount == 0)
            {
                buttonW = self.tabScrollView.bounds.size.width / self.tabArray.count;
            }
            else
            {
                buttonW = self.tabScrollView.bounds.size.width / self.showCount;
            }
        }
        
        UIButton *selectedBtn = nil;
        
        for (NSInteger i = 0; i < self.tabArray.count; i ++)
        {
            SYTabViewModel *tabModel = self.tabArray[i];
            if (self.isAutoWidth)
            {
                buttonW = [tabModel.title widthForFont:self.selectedFont withHeight:buttonH] + 20;
            }
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(lastX, 0, buttonW, buttonH);
            [self.tabScrollView insertSubview:button belowSubview:self.selectLine];
            [self.buttonArray addObject:button];
            
            button.titleLabel.font = _normalFont;
            [button setTitle:tabModel.title forState:UIControlStateNormal];
            [button setTitleColor:_normalColor forState:UIControlStateNormal];
            [button setTitleColor:_selectedColor forState:UIControlStateSelected];
            [button setTitleColor:_selectedColor forState:UIControlStateSelected|UIControlStateHighlighted];
            button.tag = i;
            [button addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            if (i == 0 || i == _selectIndex)
            {
                selectedBtn = button;
            }
            
            lastX += buttonW;
        }
        
        self.tabScrollView.contentSize = CGSizeMake(lastX, 0);
        
        if (selectedBtn)
        {
            [self tabButtonClicked:selectedBtn];
        }
    }
}

#pragma mark - 交互事件
- (void)tabButtonClicked:(UIButton *)sender
{
    if (!sender.selected)
    {
        if (self.buttonArray.count > _selectIndex)
        {
            UIButton *selectBtn = self.buttonArray[_selectIndex];
            selectBtn.titleLabel.font = self.normalFont;
            selectBtn.selected = NO;
        }
        
        _selectIndex = sender.tag;
        sender.titleLabel.font = self.selectedFont;
        sender.selected = YES;
        
        // 计算lineView坐标
        CGPoint btnCenter = sender.center;
        btnCenter.y = sender.frame.size.height - LINE_HEIGHT * 0.5;
        [UIView animateWithDuration:0.2 animations:^{
            self.selectLine.center = btnCenter;
        }];
        
        // 计算scrollView偏移
        if (self.tabScrollView.contentSize.width > self.tabScrollView.bounds.size.width)
        {
            CGFloat offsetX = btnCenter.x - self.tabScrollView.bounds.size.width * 0.5;
            
            if (offsetX > self.tabScrollView.contentSize.width - self.tabScrollView.bounds.size.width)
            {
                [self.tabScrollView setContentOffset:CGPointMake(self.tabScrollView.contentSize.width - self.tabScrollView.bounds.size.width, 0) animated:YES];
            }
            else if (offsetX < 0)
            {
                [self.tabScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
            else
            {
                [self.tabScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
            }
        }
        
        // 代理回调
        if (self.delegate && [self.delegate respondsToSelector:@selector(sy_tabViewDidChangeWithIndex:tabModel:)])
        {
            [self.delegate sy_tabViewDidChangeWithIndex:_selectIndex tabModel:self.tabArray[_selectIndex]];
        }
    }
}

#pragma mark - 逻辑处理

#pragma mark - 网络请求

#pragma mark - 代理方法实现

#pragma mark - Getter
- (NSMutableArray<UIButton *> *)buttonArray
{
    if (!_buttonArray)
    {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

#pragma mark - Setter
- (void)setSelectIndex:(NSInteger)selectIndex
{
    if (self.buttonArray.count > selectIndex)
    {
        [self tabButtonClicked:self.buttonArray[selectIndex]];
    }
}

- (void)setTabArray:(NSArray<SYTabViewModel *> *)tabArray
{
    _tabArray = tabArray;
    [self refreshTabView];
}

- (void)setShowCount:(NSUInteger)showCount
{
    if (_showCount != showCount)
    {
        _showCount = showCount;
        [self refreshTabView];
    }
}

- (void)setIsAutoWidth:(BOOL)isAutoWidth
{
    if (_isAutoWidth != isAutoWidth)
    {
        _isAutoWidth = isAutoWidth;
        [self refreshTabView];
    }
}

- (void)setNormalFont:(UIFont *)normalFont
{
    _normalFont = normalFont;
    [self refreshTabView];
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    for (UIButton *btn in self.buttonArray)
    {
        [btn setTitleColor:normalColor forState:UIControlStateNormal];
    }
}

- (void)setSelectedFont:(UIFont *)selectedFont
{
    _selectedFont = selectedFont;
    [self refreshTabView];
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
    _selectedColor = selectedColor;
    for (UIButton *btn in self.buttonArray)
    {
        [btn setTitleColor:selectedColor forState:UIControlStateSelected];
    }
}

- (void)setSelectLineColor:(UIColor *)selectLineColor
{
    _selectLineColor = selectLineColor;
    self.selectLine.backgroundColor = selectLineColor;
}

- (void)setSelectLineWidth:(CGFloat)selectLineWidth
{
    _selectLineWidth = selectLineWidth;
    
    CGRect lineFrame = self.selectLine.frame;
    lineFrame.origin.x = lineFrame.origin.x + (lineFrame.size.width - selectLineWidth) * 0.5;
    lineFrame.size.width = selectLineWidth;
    self.selectLine.frame = lineFrame;
}


@end

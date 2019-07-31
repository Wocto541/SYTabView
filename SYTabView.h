//
//  SYTabView.h
//  ZhuangheTourist
//
//  Created by ZhongJingHeTian on 2018/10/24.
//  Copyright © 2018年 wangshiyue. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 tab数据
 */
@interface SYTabViewModel : NSObject

/**
 tab名称
 */
@property (nonatomic, copy) NSString *title;

/**
 tab内容
 */
@property (nonatomic, strong, nullable) id value;

/**
 构造方法
 
 @param title 名称
 @return tab对象
 */
+ (instancetype)tabTitle:(NSString *)title;

/**
 构造方法

 @param title 名称
 @param value 内容
 @return tab对象
 */
+ (instancetype)tabTitle:(NSString *)title value:(_Nullable id)value;

@end

@protocol SYTabViewDelegate <NSObject>
@optional
- (void)sy_tabViewDidChangeWithIndex:(NSInteger)index tabModel:(SYTabViewModel *)tabModel;
@end

/**
 切换视图
 */
@interface SYTabView : UIView

#pragma mark - tab基础数据
/**
 tab的显示内容
 */
@property (nonatomic, copy) NSArray<SYTabViewModel *> *tabArray;

/**
 选中第几个
 */
@property (nonatomic, assign) NSInteger selectIndex;

/**
 选中的名称
 */
@property (nonatomic, assign, readonly) NSString *selectTitle;

/**
 代理对象
 */
@property (nonatomic, weak) id<SYTabViewDelegate> delegate;

/**
 底部线条
 */
@property (nonatomic, weak) UIView *bottomLine;

#pragma mark - tab布局
/**
 单页显示平分的按钮数量(为0时，为安装宽度平均分割；isAutoWidth为yes时，该值设置无效)
 */
@property (nonatomic, assign) NSUInteger showCount;

/**
 是否宽度自适应
 */
@property (nonatomic, assign) BOOL isAutoWidth;


#pragma mark - tab样式
/**
 未选中字体
 */
@property (nonatomic, strong) UIFont *normalFont;

/**
 未选中颜色
 */
@property (nonatomic, strong) UIColor *normalColor;

/**
 选中字体
 */
@property (nonatomic, strong) UIFont *selectedFont;

/**
 选中颜色
 */
@property (nonatomic, strong) UIColor *selectedColor;

/**
 选中线段颜色
 */
@property (nonatomic, strong) UIColor *selectLineColor;

/**
 选中线段宽度
 */
@property (nonatomic, assign) CGFloat selectLineWidth;

@end

NS_ASSUME_NONNULL_END

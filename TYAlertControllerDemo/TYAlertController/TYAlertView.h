//
//  TYAlertView.h
//  TYAlertControllerDemo
//
//  Created by tanyang on 15/9/7.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TYAlertActionStyle) {
    TYAlertActionStyleDefault,
    TYAlertActionStyleCancel,
    TYAlertActionStyleDestructive,
    TYAlertActionStyleClose,
};

@interface TYAlertAction : NSObject <NSCopying>

+ (instancetype)actionWithTitle:(NSString *)title style:(TYAlertActionStyle)style handler:(void (^)(TYAlertAction *action))handler;
+ (instancetype)actionWithImage:(UIImage *)img style:(TYAlertActionStyle)style handler:(void (^)(TYAlertAction *action))handler;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) UIImage *img;
@property (nonatomic, readonly) TYAlertActionStyle style;
@property (nonatomic, getter=isEnabled) BOOL enabled;

@end


@interface TYAlertView : UIView

@property (nonatomic, weak, readonly) UILabel *titleLable;
@property (nonatomic, weak, readonly) UILabel *messageLabel;
@property (nonatomic, strong) UIColor *topBgColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *contentFont;
@property (nonatomic, strong) UIColor *contentColor;
@property (nonatomic, strong) UIFont *tipLabelFont;
// alertView textfield array
@property (nonatomic, strong, readonly) NSArray *textFieldArray;
@property (nonatomic, strong, readonly) NSArray *titleTipArray;

// default 280, if 0 don't add width constraint,
@property (nonatomic, assign) CGFloat alertViewWidth;

// contentView space custom
@property (nonatomic, assign) CGFloat contentViewSpace;
@property (nonatomic, assign) CGFloat textFieldViewSpace;

// textLabel custom
@property (nonatomic, assign) CGFloat textLabelSpace;
@property (nonatomic, assign) CGFloat textLabelContentViewEdge;

// button custom
@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, assign) CGFloat buttonSpace;
@property (nonatomic, assign) CGFloat buttonContentViewEdge;
@property (nonatomic, assign) CGFloat buttonContentViewTop;
@property (nonatomic, assign) CGFloat buttonCornerRadius;
@property (nonatomic, strong) UIFont *buttonFont;
@property (nonatomic, strong) UIColor *buttonDefaultBgColor;
@property (nonatomic, strong) UIColor *buttonCancelBgColor;
@property (nonatomic, strong) UIColor *buttonDestructiveBgColor;

// textField custom
@property (nonatomic, strong) UIColor *textFieldBorderColor;
@property (nonatomic, strong) UIColor *textFieldBackgroudColor;
@property (nonatomic, strong) UIFont *textFieldFont;
@property (nonatomic, assign) CGFloat textFieldHeight;
@property (nonatomic, assign) CGFloat textFieldEdge;
@property (nonatomic, assign) CGFloat textFieldBorderWidth;
@property (nonatomic, assign) CGFloat textFieldContentViewEdge;

@property (nonatomic, assign) BOOL clickedAutoHide;

+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)message;

- (void)configureProperty;

- (void)addAction:(TYAlertAction *)action;

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;

- (void)addTextFieldWithConfigurationHandlerWithTitle:(NSString*)title handler:(void (^)(UITextField *textField))configurationHandler;

@end

//
//  TYAlertView.m
//  TYAlertControllerDemo
//
//  Created by tanyang on 15/9/7.
//  Copyright (c) 2015年 tanyang. All rights reserved.
//

#import "TYAlertView.h"
#import "UIView+TYAlertView.h"
#import "UIView+TYAutoLayout.h"
#import "NSString+Size.h"
@interface TYAlertAction ()
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, assign) TYAlertActionStyle style;
@property (nonatomic, copy) void (^handler)(TYAlertAction *);
@end

@implementation TYAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(TYAlertActionStyle)style handler:(void (^)(TYAlertAction *))handler
{
    return [[self alloc] initWithTitle:title style:style handler:handler];
}

+ (instancetype)actionWithImage:(UIImage *)img style:(TYAlertActionStyle)style handler:(void (^)(TYAlertAction *action))handler
{
    return [[self alloc] initWithImage:img style:style handler:handler];
}

- (instancetype)initWithTitle:(NSString *)title style:(TYAlertActionStyle)style handler:(void (^)(TYAlertAction *))handler
{
    if (self = [super init]) {
        _title = title;
        _style = style;
        _handler = handler;
        _enabled = YES;
        
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)img style:(TYAlertActionStyle)style handler:(void (^)(TYAlertAction *))handler
{
    if (self = [super init]) {
        _img = img;
        _style = style;
        _handler = handler;
        _enabled = YES;
        
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    TYAlertAction *action = [[self class]allocWithZone:zone];
    action.title = self.title;
    action.style = self.style;
    action.img = self.img;
    return action;
}

@end


@interface TYAlertView ()

// text content View
@property (nonatomic, weak) UIView *topContentView;
@property (nonatomic, weak) UIView *textContentView;
@property (nonatomic, weak) UILabel *titleLable;
@property (nonatomic, weak) UILabel *messageLabel;

@property (nonatomic, weak) UIView *textFieldContentView;
@property (nonatomic, weak) NSLayoutConstraint *textFieldTopConstraint;
@property (nonatomic, strong) NSMutableArray *textFields;
@property (nonatomic, strong) NSMutableArray *textFieldSeparateViews;

// button content View
@property (nonatomic, weak) UIView *buttonContentView;
@property (nonatomic, weak) NSLayoutConstraint *buttonTopConstraint;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) TYAlertAction *closeAction;

@end

#define kAlertViewWidth 280
#define kContentViewEdge 15
#define kContentViewSpace 15
#define kTextFieldViewSpace 20
#define kTextLabelSpace  26

#define kButtonTagOffset 1000
#define kButtonSpace     6
#define KButtonHeight    44

#define kTextFieldOffset 10000
#define kTextFieldHeight 29
#define kTextFieldEdge  8
#define KTextFieldBorderWidth 0.5

#define kCloseButtonTag 3000

@implementation TYAlertView

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self configureProperty];
        
        [self addContentViews];
        
        [self addTextLabels];
        
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message
{
    if (self = [self init]) {
        
        _titleLable.text = title;
        _messageLabel.text = message;
        
    }
    return self;
}

+ (instancetype)alertViewWithTitle:(NSString *)title message:(NSString *)message
{
    return [[self alloc]initWithTitle:title message:message];
}

#pragma mark - configure

- (void)configureProperty
{
    _clickedAutoHide = YES;
    self.backgroundColor = [UIColor whiteColor];
    _alertViewWidth = kAlertViewWidth;
    _contentViewSpace = kContentViewSpace;
    _textFieldViewSpace = kTextFieldViewSpace;//ljx
    _textLabelSpace = kTextLabelSpace;
    _textLabelContentViewEdge = kContentViewEdge;
    
    _buttonHeight = KButtonHeight;
    _buttonSpace = kButtonSpace;
    _buttonContentViewEdge = kContentViewEdge;
    _buttonContentViewTop = kContentViewSpace;
    _buttonCornerRadius = 4.0;
    _buttonFont = [UIFont fontWithName:@"HelveticaNeue" size:18];
    _buttonDefaultBgColor = [UIColor colorWithRed:52/255.0 green:152/255.0 blue:219/255.0 alpha:1];
    _buttonCancelBgColor = [UIColor colorWithRed:127/255.0 green:140/255.0 blue:141/255.0 alpha:1];
    _buttonDestructiveBgColor = [UIColor colorWithRed:231/255.0 green:76/255.0 blue:60/255.0 alpha:1];
    
    _textFieldHeight = kTextFieldHeight;
    _textFieldEdge = kTextFieldEdge;
    _textFieldBorderWidth = KTextFieldBorderWidth;
    _textFieldContentViewEdge = kContentViewEdge;
    
    _textFieldBorderColor = [UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1];
    _textFieldBackgroudColor = [UIColor whiteColor];
    _textFieldFont = [UIFont systemFontOfSize:14];
    
    self.titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    self.contentFont = [UIFont fontWithName:@"HelveticaNeue" size:15];
    self.titleColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    self.contentColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _buttons = [NSMutableArray array];
    _actions = [NSMutableArray array];
}

- (UIColor *)buttonBgColorWithStyle:(TYAlertActionStyle)style
{
    switch (style) {
        case TYAlertActionStyleDefault:
            return _buttonDefaultBgColor;
        case TYAlertActionStyleCancel:
            return _buttonCancelBgColor;
        case TYAlertActionStyleDestructive:
            return _buttonDestructiveBgColor;
            
        default:
            return nil;
    }
}

#pragma mark - add contentview

- (void)addContentViews
{
    UIView *topContentView = [[UIView alloc]init];
    [self addSubview:topContentView];
    _topContentView = topContentView;
    topContentView.userInteractionEnabled = YES;
    _topContentView.backgroundColor = self.topBgColor;
    
    UIView *textContentView = [[UIView alloc]init];
    [self addSubview:textContentView];
    _textContentView = textContentView;
    
    UIView *textFieldContentView = [[UIView alloc]init];
    [self addSubview:textFieldContentView];
    _textFieldContentView = textFieldContentView;
    
    UIView *buttonContentView = [[UIView alloc]init];
    buttonContentView.userInteractionEnabled = YES;
    [self addSubview:buttonContentView];
    _buttonContentView = buttonContentView;
}

- (void)addTextLabels
{
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = self.titleFont;
    titleLabel.textColor = self.titleColor;
    [_textContentView addSubview:titleLabel];
    _titleLable = titleLabel;
    
    UILabel *messageLabel = [[UILabel alloc]init];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = self.contentFont;
    messageLabel.textColor = self.contentColor;
    [_textContentView addSubview:messageLabel];
    _messageLabel = messageLabel;
}

- (void)didMoveToSuperview
{
    if (self.superview) {
        [self layoutContentViews];
        [self layoutTextLabels];
    }
}

- (void)addAction:(TYAlertAction *)action
{
    if (action.style == TYAlertActionStyleClose)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.clipsToBounds = YES;
        [button setBackgroundImage:action.img forState:UIControlStateNormal];
        button.enabled = action.enabled;
        button.tag = kCloseButtonTag;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_topContentView addSubview:button];
        self.closeAction = action;
        self.closeButton = button;
        
        [self layoutContentViews];
    }
    else{
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = _buttonCornerRadius;
        [button setTitle:action.title forState:UIControlStateNormal];
        button.titleLabel.font = _buttonFont;
        button.backgroundColor = [self buttonBgColorWithStyle:action.style];
        button.enabled = action.enabled;
        button.tag = kButtonTagOffset + _buttons.count;
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button addTarget:self action:@selector(actionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_buttonContentView addSubview:button];
        [_buttons addObject:button];
        [_actions addObject:action];
        
        if (_buttons.count == 1) {
            [self layoutContentViews];
            [self layoutTextLabels];
        }
        
        [self layoutButtons];
    }
    
}

- (void)addTextFieldWithConfigurationHandlerWithTitle:(NSString*)title handler:(void (^)(UITextField *textField))configurationHandler
{
    [self addTextFieldWithConfigurationHandler:configurationHandler];
    
    UIFont *titlefont = [UIFont systemFontOfSize:12.0];
    CGSize titleSize = [title tt_sizeWithFont:titlefont];
    UITextField *textField = [_textFields lastObject];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleSize.width+15, _textFieldHeight)];
    leftView.backgroundColor = [UIColor clearColor];
    textField.leftView = leftView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, titleSize.width, _textFieldHeight)];
    titleLabel.font = titlefont;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = title;
    [leftView addSubview:titleLabel];
}
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler
{
    if (_textFields == nil) {
        _textFields = [NSMutableArray array];
    }
    
    UITextField *textField = [[UITextField alloc]init];
    textField.tag = kTextFieldOffset + _textFields.count;
    textField.font = _textFieldFont;
    textField.translatesAutoresizingMaskIntoConstraints = NO;


    
    [_textFieldContentView addSubview:textField];
    [_textFields addObject:textField];
    
//    if (_textFields.count > 1)
    {
        if (_textFieldSeparateViews == nil) {
            _textFieldSeparateViews = [NSMutableArray array];
        }
        UILabel *tipLabel = [[UILabel alloc]init];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.font = self.tipLabelFont;
        tipLabel.textColor = [UIColor redColor];
        [_textFieldContentView addSubview:tipLabel];
        [_textFieldSeparateViews addObject:tipLabel];
    }
    
    [self layoutTextFields];
    
    if (configurationHandler) {
        configurationHandler(textField);
    }
}

- (NSArray *)textFieldArray
{
    return _textFields;
}

- (NSArray *)titleTipArray
{
    return _textFieldSeparateViews;
}


#pragma mark - layout contenview

- (void)layoutContentViews
{
    if (!_textContentView.translatesAutoresizingMaskIntoConstraints) {
        // layout done
        return;
    }
    if (_alertViewWidth) {
        [self addConstraintWidth:_alertViewWidth height:0];
    }
    
    _topContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraintWithViewHeight:_topContentView topView:self leftView:self bottomView:self rightView:self edgeInset:UIEdgeInsetsZero height:40];
    
    if (self.closeButton)
    {
        UIImage *img = self.closeAction.img;
        CGSize imgSize = img.size;
        UIEdgeInsets inset = UIEdgeInsetsMake(kContentViewEdge, 0, 0, -1*kContentViewEdge);
        [_topContentView addConstraintWithViewWidthHeight:self.closeButton topView:_topContentView rightView:_topContentView edgeInset:inset width:imgSize.width height:imgSize.height];
    }
    
    // textContentView
    _textContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    UIEdgeInsets titleInset = UIEdgeInsetsMake(_contentViewSpace, _textLabelContentViewEdge, 0, -_textLabelContentViewEdge);
    if (self.closeButton)
    {
        titleInset = UIEdgeInsetsMake(_contentViewSpace, _textLabelContentViewEdge + 20, 0, -1 * (_textLabelContentViewEdge + 20));
    }
    
    [self addConstraintWithView:_textContentView topView:self leftView:self bottomView:nil rightView:self edgeInset:titleInset];
    
    // textFieldContentView
    _textFieldContentView.translatesAutoresizingMaskIntoConstraints = NO;
    _textFieldTopConstraint = [self addConstraintWithTopView:_textContentView toBottomView:_textFieldContentView constant:0];
    
    [self addConstraintWithView:_textFieldContentView topView:nil leftView:self bottomView:nil rightView:self edgeInset:UIEdgeInsetsMake(0, _textFieldContentViewEdge, 0, -_textFieldContentViewEdge)];
    
    // buttonContentView
    _buttonContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    _buttonTopConstraint = [self addConstraintWithTopView:_textFieldContentView toBottomView:_buttonContentView constant:_buttonContentViewTop];
    
    [self addConstraintWithView:_buttonContentView topView:nil leftView:self bottomView:self rightView:self edgeInset:UIEdgeInsetsMake(0, _buttonContentViewEdge, -_contentViewSpace, -_buttonContentViewEdge)];
}

- (void)layoutTextLabels
{
    if (!_titleLable.translatesAutoresizingMaskIntoConstraints && !_messageLabel.translatesAutoresizingMaskIntoConstraints) {
        // layout done
        return;
    }
    // title
    _titleLable.translatesAutoresizingMaskIntoConstraints = NO;
    [_textContentView addConstraintWithView:_titleLable topView:_textContentView leftView:_textContentView bottomView:nil rightView:_textContentView edgeInset:UIEdgeInsetsZero];
    
    // message
    _messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_textContentView addConstraintWithTopView:_titleLable toBottomView:_messageLabel constant:_textLabelSpace];
    [_textContentView addConstraintWithView:_messageLabel topView:nil leftView:_textContentView bottomView:_textContentView rightView:_textContentView edgeInset:UIEdgeInsetsZero];
}

- (void)layoutButtons
{
    UIButton *button = _buttons.lastObject;
    if (_buttons.count == 1) {
        _buttonTopConstraint.constant = -_buttonContentViewTop;
        [_buttonContentView addConstraintToView:button edgeInset:UIEdgeInsetsZero];
        [button addConstraintWidth:0 height:_buttonHeight];
    }else if (_buttons.count == 2) {
        UIButton *firstButton = _buttons.firstObject;
        [_buttonContentView removeConstraintWithView:firstButton attribute:NSLayoutAttributeRight];
        [_buttonContentView addConstraintWithView:button topView:_buttonContentView leftView:nil bottomView:nil rightView:_buttonContentView edgeInset:UIEdgeInsetsZero];
        [_buttonContentView addConstraintWithLeftView:firstButton toRightView:button constant:_buttonSpace];
        [_buttonContentView addConstraintEqualWithView:button widthToView:firstButton heightToView:firstButton];
    }else {
        if (_buttons.count == 3) {
            UIButton *firstBtn = _buttons[0];
            UIButton *secondBtn = _buttons[1];
            [_buttonContentView removeConstraintWithView:firstBtn attribute:NSLayoutAttributeRight];
            [_buttonContentView removeConstraintWithView:firstBtn attribute:NSLayoutAttributeBottom];
            [_buttonContentView removeConstraintWithView:secondBtn attribute:NSLayoutAttributeTop];
            [_buttonContentView addConstraintWithView:firstBtn topView:nil leftView:nil bottomView:nil rightView:_buttonContentView edgeInset:UIEdgeInsetsZero];
            [_buttonContentView addConstraintWithTopView:firstBtn toBottomView:secondBtn constant:_buttonSpace];
            
        }
        
        UIButton *lastSecondBtn = _buttons[_buttons.count - 2];
        [_buttonContentView removeConstraintWithView:lastSecondBtn attribute:NSLayoutAttributeBottom];
        [_buttonContentView addConstraintWithTopView:lastSecondBtn toBottomView:button constant:_buttonSpace];
        [_buttonContentView addConstraintWithView:button topView:nil leftView:_buttonContentView bottomView:_buttonContentView rightView:_buttonContentView edgeInset:UIEdgeInsetsZero];
        [_buttonContentView addConstraintEqualWithView:button widthToView:nil heightToView:lastSecondBtn];
    }
}

- (void)layoutTextFields
{
    UITextField *textField = _textFields.lastObject;
    
    textField.backgroundColor = _textFieldBackgroudColor;
    textField.layer.masksToBounds = YES;
    textField.layer.cornerRadius = 8;
    textField.layer.borderWidth = _textFieldBorderWidth;
    textField.layer.borderColor = _textFieldBorderColor.CGColor;
    
    if (_textFields.count == 1)
    {
        _textFieldTopConstraint.constant = -_contentViewSpace;
        [_textFieldContentView addConstraintToView:textField edgeInset:UIEdgeInsetsMake(_textFieldBorderWidth, _textFieldEdge, -1*(_textFieldBorderWidth+_textFieldViewSpace), -_textFieldEdge)];
        [textField addConstraintWidth:0 height:_textFieldHeight];
    }
    else
    {
        // textField
        UITextField *lastSecondTextField = _textFields[_textFields.count - 2];
        [_textFieldContentView removeConstraintWithView:lastSecondTextField attribute:NSLayoutAttributeBottom];
        [_textFieldContentView addConstraintWithTopView:lastSecondTextField toBottomView:textField constant:_textFieldBorderWidth+_textFieldViewSpace];
        [_textFieldContentView addConstraintWithView:textField topView:nil leftView:_textFieldContentView bottomView:_textFieldContentView rightView:_textFieldContentView edgeInset:UIEdgeInsetsMake(0, _textFieldEdge, -_textFieldBorderWidth, -_textFieldEdge)];
        [_textFieldContentView addConstraintEqualWithView:textField widthToView:nil heightToView:lastSecondTextField];
        
        lastSecondTextField.backgroundColor = _textFieldBackgroudColor;
        lastSecondTextField.layer.masksToBounds = YES;
        lastSecondTextField.layer.cornerRadius = 8;
        lastSecondTextField.layer.borderWidth = _textFieldBorderWidth;
        lastSecondTextField.layer.borderColor = _textFieldBorderColor.CGColor;
        
        textField.backgroundColor = _textFieldBackgroudColor;
        textField.layer.masksToBounds = YES;
        textField.layer.cornerRadius = 8;
        textField.layer.borderWidth = _textFieldBorderWidth;
        textField.layer.borderColor = _textFieldBorderColor.CGColor;
    }
}

#pragma mark - action

- (void)actionButtonClicked:(UIButton *)button
{
    NSInteger btnTag = button.tag;
    if (btnTag == kCloseButtonTag) {
        TYAlertAction *action = self.closeAction;
        [self hideView];
        if (action.handler) {
            action.handler(action);
        }
    }
    else
    {
        TYAlertAction *action = _actions[btnTag - kButtonTagOffset];
        
        if (_clickedAutoHide) {
            [self hideView];
        }
        
        if (action.handler) {
            action.handler(action);
        }
    }
    
}

//- (void)dealloc
//{
//    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
//}

@end

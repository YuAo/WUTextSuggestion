//
//  WUTextSuggestionDisplayController.m
//  WUTextSuggestionController
//
//  Created by YuAo on 5/11/13.
//  Copyright (c) 2013 YuAo. All rights reserved.
//

#import "WUTextSuggestionDisplayController.h"
#import <objc/runtime.h>

NSString * const WUTextSuggestionDisplayControllerUIMenuControllerActionSelectorPrefix = @"textSuggestionDisplayControllerUIMenuControllerAction_";

NSString * const WUTextSuggestionDisplayItemAssociationKey = @"WUTextSuggestionDisplayItemAssociationKey";

@implementation WUTextSuggestionDisplayItem

- (id)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        _title = [title copy];
    }
    return self;
}

@end

@interface UIMenuItem (WUTextSuggestionDisplayController)

@property (nonatomic,strong) WUTextSuggestionDisplayItem *textSuggestionDisplayItem;

@end

@implementation UIMenuItem (WUTextSuggestionDisplayController)

- (void)setTextSuggestionDisplayItem:(WUTextSuggestionDisplayItem *)textSuggestionDisplayItem {
    objc_setAssociatedObject(self, &WUTextSuggestionDisplayItemAssociationKey, textSuggestionDisplayItem, OBJC_ASSOCIATION_RETAIN);
}

- (WUTextSuggestionDisplayItem *)textSuggestionDisplayItem {
    return objc_getAssociatedObject(self, &WUTextSuggestionDisplayItemAssociationKey);
}

@end

static SEL WUTextSuggestionDisplayControllerUIMenuControllerActionSelectorForMenuItemWithTitle(NSString *title) {
    return NSSelectorFromString([NSString stringWithFormat:@"%@%x",WUTextSuggestionDisplayControllerUIMenuControllerActionSelectorPrefix,title.hash]);
}

static BOOL WUTextSuggestionDisplayControllerUIMenuControllerActionSelectorMatchesMenuItemTitle(SEL selector, NSString *title) {
    NSString *hash = [NSStringFromSelector(selector) stringByReplacingOccurrencesOfString:WUTextSuggestionDisplayControllerUIMenuControllerActionSelectorPrefix withString:@""];
    if ([hash isEqualToString:[NSString stringWithFormat:@"%x",title.hash]]) {
        return YES;
    } else {
        return NO;
    }
}

@interface WUTextSuggestionDisplayController ()
@property (nonatomic,weak)   UITextView *textView;
@property (nonatomic)        BOOL       suggesting;

@property (nonatomic,copy)   NSString               *suggestionQuery;
@property (nonatomic)        WUTextSuggestionType   suggestionType;
@property (nonatomic)        NSRange                suggestionRange;
@end

@implementation WUTextSuggestionDisplayController

static WUTextSuggestionDisplayController __weak *_activeTextSuggestionDisplayController;

+ (WUTextSuggestionDisplayController *)activeTextSuggestionDisplayController {
    return _activeTextSuggestionDisplayController;
}

+ (void)setActiveTextSuggestionDisplayController:(WUTextSuggestionDisplayController *)activeTextSuggestionDisplayController {
    _activeTextSuggestionDisplayController = activeTextSuggestionDisplayController;
}

- (void)beginSuggestingForTextView:(UITextView *)textView {
    self.textView = textView;
    self.suggesting = YES;
}

- (void)endSuggesting {
    [self.class setActiveTextSuggestionDisplayController:nil];
    [UIMenuController sharedMenuController].menuItems = nil;
    self.suggesting = NO;
    self.textView = nil;
}

- (void)reloadSuggestionsWithType:(WUTextSuggestionType)suggestionType query:(NSString *)suggestionQuery range:(NSRange)suggestionRange {
    self.suggestionRange = suggestionRange;
    self.suggestionType = suggestionType;
    self.suggestionQuery = suggestionQuery;
    [self.class setActiveTextSuggestionDisplayController:nil];
    [UIMenuController sharedMenuController].menuItems = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(delayShowSuggestionMenuController) withObject:nil afterDelay:0.2];
}

- (void)delayShowSuggestionMenuController {
    void (^showMenuControllerWithSuggestionDisplayItems)(NSArray *suggestionDisplayItems) = ^(NSArray *suggestionItems){
        if (self.suggesting && self.textView) {
            NSMutableArray *meunItems = [NSMutableArray array];
            [suggestionItems enumerateObjectsUsingBlock:^(WUTextSuggestionDisplayItem *obj, NSUInteger idx, BOOL *stop) {
                UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:obj.title action:WUTextSuggestionDisplayControllerUIMenuControllerActionSelectorForMenuItemWithTitle(obj.title)];
                item.textSuggestionDisplayItem = obj;
                [meunItems addObject:item];
            }];
            if (meunItems.count) {
                CGRect caretRect = [self.textView caretRectForPosition:self.textView.selectedTextRange.start];
                [self.class setActiveTextSuggestionDisplayController:self];
                [UIMenuController sharedMenuController].menuItems = meunItems;
                [[UIMenuController sharedMenuController] setTargetRect:caretRect inView:self.textView];
                [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
            }
        }
    };
    if ([self.dataSource respondsToSelector:@selector(textSuggestionDisplayController:suggestionDisplayItemsForSuggestionType:query:callback:)]) {
        [self.dataSource textSuggestionDisplayController:self suggestionDisplayItemsForSuggestionType:self.suggestionType query:self.suggestionQuery callback:^(NSArray *suggestionDisplayItems) {
            dispatch_async(dispatch_get_main_queue(), ^{
                showMenuControllerWithSuggestionDisplayItems(suggestionDisplayItems); 
            });
        }];
    } else if ([self.dataSource respondsToSelector:@selector(textSuggestionDisplayController:suggestionDisplayItemsForSuggestionType:query:)]) {
        showMenuControllerWithSuggestionDisplayItems([self.dataSource textSuggestionDisplayController:self suggestionDisplayItemsForSuggestionType:self.suggestionType query:self.suggestionQuery]);
    } else {
        WUTextSuggestionDisplayItem *item = [[WUTextSuggestionDisplayItem alloc] initWithTitle:@"No DataSource Provided"];
        showMenuControllerWithSuggestionDisplayItems(@[item]);
    }
}

- (void)textSuggestionDisplayItemTapped:(WUTextSuggestionDisplayItem *)item {
    if (item.customActionBlock) {
        item.customActionBlock(self.suggestionType,self.suggestionQuery,self.suggestionRange);
    } else {
        NSRange suggestionRange = self.suggestionRange;
        NSString *suggestionString = item.title;
        NSString *insertString = [suggestionString stringByAppendingString:@" "];
        if (self.textView.text.length > suggestionRange.location + suggestionRange.length) {
            if ([[self.textView.text substringWithRange:NSMakeRange(suggestionRange.location, suggestionRange.length + 1)] hasSuffix:@" "]) {
                insertString = suggestionString;
            }
        }
        self.textView.text = [self.textView.text stringByReplacingCharactersInRange:suggestionRange withString:insertString];
    }
}

@end

@implementation WUTextSuggestionController (WUTextSuggestionDisplayController)

- (id)initWithTextView:(UITextView *)textView suggestionDisplayController:(WUTextSuggestionDisplayController *)suggestionDisplayController {
    if (self = [self initWithTextView:textView]) {
        __weak __typeof(&*self)weakSelf = self;
        [self setShouldBeginSuggestingBlock:^{
            [suggestionDisplayController beginSuggestingForTextView:weakSelf.textView];
        }];
        [self setShouldReloadSuggestionsBlock:^(WUTextSuggestionType type, NSString *query, NSRange range) {
            [suggestionDisplayController reloadSuggestionsWithType:type query:query range:range];
        }];
        [self setShouldEndSuggestingBlock:^{
            [suggestionDisplayController endSuggesting];
        }];
    }
    return self;
}

@end

static void class_swizzleSelector(Class class, SEL originalSelector, SEL newSelector)
{
    Method origMethod = class_getInstanceMethod(class, originalSelector);
    Method newMethod = class_getInstanceMethod(class, newSelector);
    if(class_addMethod(class, originalSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, newSelector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@interface UITextView (WUTextSuggestionDisplayController)

@end

@implementation UITextView (WUTextSuggestionDisplayController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            class_swizzleSelector(self, @selector(canPerformAction:withSender:), @selector(textView_WUTextSuggestionDisplayController_canPerformAction:withSender:));
            class_swizzleSelector(self, @selector(methodSignatureForSelector:), @selector(textView_WUTextSuggestionDisplayController_methodSignatureForSelector:));
            class_swizzleSelector(self, @selector(forwardInvocation:), @selector(textView_WUTextSuggestionDisplayController_forwardInvocation:));
        }
    });
}

- (BOOL)textView_WUTextSuggestionDisplayController_canPerformAction:(SEL)action withSender:(id)sender {
    if ([NSStringFromSelector(action) hasPrefix:WUTextSuggestionDisplayControllerUIMenuControllerActionSelectorPrefix]) {
        if ([WUTextSuggestionDisplayController activeTextSuggestionDisplayController].suggesting) {
            return YES;
        } else {
            return NO;
        }
    }
    if ([WUTextSuggestionDisplayController activeTextSuggestionDisplayController].suggesting) {
        if (action == @selector(paste:) || action == @selector(selectAll:) || action == @selector(select:)) {
            return NO;
        }
    }
    return [self textView_WUTextSuggestionDisplayController_canPerformAction:action withSender:sender];
}

- (void)textSuggestionDisplayControllerUIMenuControllerAction_xxxx {
    //A Placeholder Method
    return;
}

- (NSMethodSignature *)textView_WUTextSuggestionDisplayController_methodSignatureForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) hasPrefix:WUTextSuggestionDisplayControllerUIMenuControllerActionSelectorPrefix]) {
        return [self textView_WUTextSuggestionDisplayController_methodSignatureForSelector:@selector(textSuggestionDisplayControllerUIMenuControllerAction_xxxx)];
    } else {
        return [self textView_WUTextSuggestionDisplayController_methodSignatureForSelector:aSelector];
    }
}

- (void)textView_WUTextSuggestionDisplayController_forwardInvocation:(NSInvocation *)anInvocation {
    if ([NSStringFromSelector(anInvocation.selector) hasPrefix:WUTextSuggestionDisplayControllerUIMenuControllerActionSelectorPrefix]) {
        [[UIMenuController sharedMenuController].menuItems enumerateObjectsUsingBlock:^(UIMenuItem *obj, NSUInteger idx, BOOL *stop) {
            if (WUTextSuggestionDisplayControllerUIMenuControllerActionSelectorMatchesMenuItemTitle(anInvocation.selector, obj.title)) {
                [[WUTextSuggestionDisplayController activeTextSuggestionDisplayController] textSuggestionDisplayItemTapped:obj.textSuggestionDisplayItem];
            }
        }];
    } else {
        [self textView_WUTextSuggestionDisplayController_forwardInvocation:anInvocation];
    }
}

@end
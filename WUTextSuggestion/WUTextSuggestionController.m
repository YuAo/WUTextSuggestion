//
//  WUTextSuggestionControl.m
//  WeicoUI
//
//  Created by YuAo on 5/8/13.
//  Copyright (c) 2013 微酷奥(北京)科技有限公司. All rights reserved.
//

#import "WUTextSuggestionController.h"
#import <objc/runtime.h>

@interface WUTextSuggestionController ()

@property (nonatomic,weak,readwrite)          UITextView *textView;

@property (nonatomic,strong)                  NSRegularExpression *checkingRegularExpression;

@property (nonatomic,readwrite,getter = isSuggesting) BOOL      suggesting;
@property (nonatomic,readwrite)                       NSRange   suggestionRange;

@end

@implementation WUTextSuggestionController

- (id)initWithTextView:(UITextView *)textView {
    if (self = [super init]) {
        self.textView = textView;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:self.textView];
        [self.textView addObserver:self forKeyPath:@"selectedTextRange" options:NSKeyValueObservingOptionNew context:NULL];
        
        self.textView.textSuggestionController = self;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.textView removeObserver:self forKeyPath:@"selectedTextRange"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.textView && [keyPath isEqualToString:@"selectedTextRange"]) {
        [self textChanged];
    }
}

- (void)textViewTextDidChange:(NSNotification *)notification {
    [self textChanged];
}

#pragma mark - 

- (void)setSuggesting:(BOOL)suggesting {
    if (_suggesting != suggesting) {
        _suggesting = suggesting;
        if (suggesting) {
            if (self.shouldBeginSuggestingBlock) {
                self.shouldBeginSuggestingBlock();
            }
        } else {
            if (self.shouldEndSuggestingBlock) {
                self.shouldEndSuggestingBlock();
            }
        }
    }
}

- (NSRegularExpression *)checkingRegularExpression {
    if (!_checkingRegularExpression) {
        _checkingRegularExpression = [NSRegularExpression regularExpressionWithPattern:@"[@#]([^\\s:：@#]?)+$?" options:NSRegularExpressionCaseInsensitive error:NULL];
    }
    return _checkingRegularExpression;
}

- (void)textChanged {
    __block NSString *word = nil;
    __block NSRange range = NSMakeRange(NSNotFound, 0);
    
    [self.checkingRegularExpression enumerateMatchesInString:self.textView.text
                                                     options:0
                                                       range:NSMakeRange(0, self.textView.text.length)
                                                  usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
    {
         NSRange textSelectedRange = self.textView.selectedRange;
         if (textSelectedRange.location > result.range.location && textSelectedRange.location <= result.range.location + result.range.length) {
             word = [self.textView.text substringWithRange:result.range];
             range = result.range;
             *stop = YES;
         }
     }];
    
    if (word.length >= 1 && range.location != NSNotFound) {
        NSString *first = [word substringToIndex:1];
        NSString *rest = [word substringFromIndex:1];
        if ([first isEqualToString:@"@"] && (self.suggestionType & WUTextSuggestionTypeAt)) {
            self.suggesting = YES;
            self.suggestionRange = NSMakeRange(range.location + 1, range.length - 1);
            if (self.shouldReloadSuggestionsBlock) {
                self.shouldReloadSuggestionsBlock(WUTextSuggestionTypeAt,rest,self.suggestionRange);
            }
        }else{
            self.suggestionRange = NSMakeRange(NSNotFound, 0);
            self.suggesting = NO;
        }
    } else {
        self.suggestionRange = NSMakeRange(NSNotFound, 0);
        self.suggesting = NO;
    }
}

@end

NSString * const WUTextSuggestionControllerAssociationKey = @"WUTextSuggestionControllerAssociationKey";

@implementation UITextView (WUTextSuggestionController)

- (void)setTextSuggestionController:(WUTextSuggestionController *)textSuggestionController {
    objc_setAssociatedObject(self, &WUTextSuggestionControllerAssociationKey, textSuggestionController, OBJC_ASSOCIATION_RETAIN);
}

- (WUTextSuggestionController *)textSuggestionController {
    return objc_getAssociatedObject(self, &WUTextSuggestionControllerAssociationKey);
}

@end


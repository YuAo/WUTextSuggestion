//
//  WUTextSuggestionControl.h
//  WeicoUI
//
//  Created by YuAo on 5/8/13.
//  Copyright (c) 2013 微酷奥(北京)科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WUTextSuggestionType) {
    WUTextSuggestionTypeNone = 0,
    WUTextSuggestionTypeAt = 1 << 0
};

@interface WUTextSuggestionController : NSObject

@property (nonatomic) WUTextSuggestionType suggestionType;

@property (nonatomic,copy) void (^shouldBeginSuggestingBlock)(void);
@property (nonatomic,copy) void (^shouldReloadSuggestionsBlock)(WUTextSuggestionType suggestionType, NSString *suggestionQuery, NSRange suggestionRange);
@property (nonatomic,copy) void (^shouldEndSuggestingBlock)(void);

@property (nonatomic,weak,readonly) UITextView *textView;
- (id)initWithTextView:(UITextView *)textView;

@end


@interface UITextView (WUTextSuggestionController)

@property (nonatomic,strong) WUTextSuggestionController *textSuggestionController;

@end

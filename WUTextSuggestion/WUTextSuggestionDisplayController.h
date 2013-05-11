//
//  WUTextSuggestionDisplayController.h
//  WUTextSuggestionController
//
//  Created by YuAo on 5/11/13.
//  Copyright (c) 2013 YuAo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WUTextSuggestionController.h"

@interface WUTextSuggestionDisplayItem : NSObject

@property (nonatomic,copy,readonly)  NSString *title;
@property (nonatomic,copy)           void     (^customActionBlock)(void);

- (id)initWithTitle:(NSString *)title;

@end


@protocol WUTextSuggestionDisplayControllerDataSource;

@interface WUTextSuggestionDisplayController : NSObject

@property (nonatomic,weak) id<WUTextSuggestionDisplayControllerDataSource> dataSource;

- (void)beginSuggestingForTextView:(UITextView *)textView;

- (void)endSuggesting;

- (void)reloadSuggestionsWithType:(WUTextSuggestionType)suggestionType query:(NSString *)suggestionQuery range:(NSRange)suggestionRange;

@end


@protocol WUTextSuggestionDisplayControllerDataSource <NSObject>

@optional

//Sync
- (NSArray *)textSuggestionDisplayController:(WUTextSuggestionDisplayController *)textSuggestionDisplayController
     suggestionDisplayItemsForSuggestionType:(WUTextSuggestionType)suggestionType
                                       query:(NSString *)suggestionQuery;

//Async
- (void)textSuggestionDisplayController:(WUTextSuggestionDisplayController *)textSuggestionDisplayController
suggestionDisplayItemsForSuggestionType:(WUTextSuggestionType)suggestionType
                                  query:(NSString *)suggestionQuery
                               callBack:(void (^)(NSArray *suggestionDisplayItems))gotSuggestionDisplayItemsBlock;

@end


@interface WUTextSuggestionController (WUTextSuggestionDisplayController)

- (id)initWithTextView:(UITextView *)textView suggestionDisplayController:(WUTextSuggestionDisplayController *)suggestionDisplayController;

@end

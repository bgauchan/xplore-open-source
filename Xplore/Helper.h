//
//  Helper.h
//  Memorandum
//
//  Created by Bardan Gauchan on 1/1/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helper : NSObject

+ (UIColor *)getColorFromHex:(int)hex;
+ (UIImage *)getImageFromColor:(int)hex;
+ (UIBarButtonItem *)getBarButtonItemUsingImageName:(NSString *)imageName withSelector:(SEL)selectorAction forTarget:(id)sender;

+ (NSString *)getStringFromArrayOfStrings:(NSArray *)strings;
+ (UIFont *)getDefaultMainFont;
+ (UIFont *)getDefaultRegularFont;
+ (UIFont *)getDefaultSmallFont;
+ (NSString *)getRandomPassword;

@end

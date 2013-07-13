//
//  Helper.m
//  Memorandum
//
//  Created by Bardan Gauchan on 1/1/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import "Helper.h"
#import <Parse/Parse.h>

@implementation Helper

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


+ (UIColor *)getColorFromHex:(int)hex
{
    return UIColorFromRGB(hex);
}

+ (UIBarButtonItem *)getBarButtonItemUsingImageName:(NSString *)imageName withSelector:(SEL)selectorAction forTarget:(id)sender
{
    // set up bar buttons for this view
    UIImage* img = [UIImage imageNamed:imageName];
    CGRect imgFrame = CGRectMake(0, 0, img.size.width, img.size.height);
    
    UIButton *button = [[UIButton alloc] initWithFrame:imgFrame];
    [button setBackgroundImage:img forState:UIControlStateNormal];
    
    if(selectorAction)
    {
        [button addTarget:sender action:selectorAction forControlEvents:UIControlEventTouchUpInside];
    }
    
    [button setShowsTouchWhenHighlighted:YES];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIImage *)getImageFromColor:(int)hex
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[Helper getColorFromHex:hex].CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

+ (NSString *)getStringFromArrayOfStrings:(NSArray *)strings
{
    NSString *stringToReturn = @"";
    
    for(NSString *string in strings)
    {
        if(string == [strings lastObject])
        {
            stringToReturn = [stringToReturn stringByAppendingString:string];
        }
        else
        {
            stringToReturn = [stringToReturn stringByAppendingString:string];
            stringToReturn = [stringToReturn stringByAppendingString:@", "];
        }
    }
    
    return stringToReturn;
}

+ (UIFont *)getDefaultMainFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:18];
}

+ (UIFont *)getDefaultRegularFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
}

+ (UIFont *)getDefaultSmallFont
{
    return [UIFont fontWithName:@"HelveticaNeue" size:14];
}

+ (NSString *)getRandomPassword
{
    NSInteger NUMBER_OF_CHARS = 30;
    
    unichar characters[NUMBER_OF_CHARS];
    for( int index=0; index < NUMBER_OF_CHARS; ++index )
    {
        characters[ index ] = 'A' + arc4random_uniform(26) ;
    }
    
    return [ NSString stringWithCharacters:characters length:NUMBER_OF_CHARS ] ;
}

@end

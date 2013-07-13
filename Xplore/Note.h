//
//  Note.h
//  Xplore
//
//  Created by Bardan Gauchan on 6/18/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "EvernoteNoteStore.h"

@interface Note : NSObject

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) EDAMGuid notebookGuid;
@property (nonatomic, strong) PFFile *thumbnail;
@property (nonatomic, strong) NSString *sourceUrl;
@property (nonatomic, strong) NSString *site;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic) int numberOfSaves;
@property (nonatomic, strong) NSDate *createdDate;
@property (nonatomic, strong) EDAMNote *noteObject;
@property (nonatomic) BOOL featured;
@property (nonatomic, strong) PFFile *noteFile;

- (Note *)initWithPFObject:(PFObject *)noteObject;

- (PFObject *)getParseNoteObject;

@end

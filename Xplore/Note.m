//
//  Note.m
//  Xplore
//
//  Created by Bardan Gauchan on 6/18/13.
//  Copyright (c) 2013 Bardan Gauchan. All rights reserved.
//

#import "Note.h"
#import <Parse/Parse.h>
#import "ENMLUtility.h"
#import "EvernoteUserStore+Extras.h"

@implementation Note

- (Note *)initWithPFObject:(PFObject *)noteObject
{
    Note *note = [[Note alloc] init];
    note.objectId = [noteObject valueForKey:@"objectId"];
    note.title = [noteObject valueForKey:@"title"];
    note.text = [noteObject valueForKey:@"text"];
    note.thumbnail = [noteObject valueForKey:@"thumbnail"];
    note.sourceUrl = [noteObject valueForKey:@"url"];
    note.site = [noteObject valueForKey:@"site"];
    note.tags = [noteObject valueForKey:@"tags"];
    note.numberOfSaves = [[noteObject valueForKey:@"saves"] intValue];
    note.createdDate = [noteObject valueForKey:@"createdAt"];
    note.noteFile = [noteObject valueForKey:@"file"];
    PFUser *user = [noteObject valueForKey:@"user"];
    note.username = [user valueForKey:@"username"];
    note.user = [user valueForKey:@"name"];
    
    return note;
}

- (PFObject *)getParseNoteObject;
{
    if(!self.sourceUrl)
        self.sourceUrl = @"";
    
    PFObject *noteObject = [[PFObject alloc] initWithClassName:@"Note"];
    [noteObject setValue:self.objectId forKey:@"objectId"];
    [noteObject setValue:self.title forKey:@"title"];
    [noteObject setValue:self.text forKey:@"text"];
    [noteObject setValue:self.sourceUrl forKey:@"url"];
    [noteObject setValue:self.tags forKey:@"tags"];
    [noteObject setValue:self.thumbnail forKey:@"thumbnail"];
    [noteObject setValue:[PFUser currentUser] forKey:@"user"];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.noteObject];
    PFFile *file = [PFFile fileWithData:data];
    [noteObject setValue:file forKey:@"file"];
    
    return noteObject;
}

@end

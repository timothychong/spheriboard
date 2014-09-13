//
//  PersistenceManager.h
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PersistenceManager : NSObject

@property (nonatomic) NSMutableArray * pathData;
+ (id)sharedManager;
@end
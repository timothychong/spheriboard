//
//  conversion.h
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface conversion : NSObject

+(CGPoint) stCenterCoordinate:(CGPoint) point;

+(CGPoint) xYToDB:(CGPoint) pt givenPhi:(double) phi
            theta:(double) theta andOrientation:(double) orientation;

+(CGPoint) dBToXY:(CGPoint) pt givenPhi:(double) phi
            theta:(double) theta andOrientation:(double) orientation;

@end

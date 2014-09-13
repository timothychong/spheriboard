//
//  conversion.m
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import "conversion.h"



@implementation conversion

+(CGPoint)stCenterCoordinate:(CGPoint)pt
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    if (pt.x < 0 || pt.y < 0 || pt.x > width || pt.y > height) {
        [NSException raise:@"Conversion Error" format:@"Input coordinate is outside the bound of the screen"];
    }
    
    return CGPointMake(pt.x / width * 16.9 - 8.45, pt.y / height  * 30 - 15);
    
}

@end

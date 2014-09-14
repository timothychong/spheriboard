//
//  ColorPickerView.m
//  presentimote
//
//  Created by Timothy Chong on 9/14/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import "ColorPickerView.h"
#define MAS_SHORTHAND
#import <Masonry/Masonry.h>

@implementation ColorPickerView

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.mainColor makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).offset(8);
            make.left.equalTo(self.left).offset(8);
            
        }];
        [self.color1 makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).offset(8 + 4 * 1);
            make.left.equalTo(self.left).offset(8);
            
        }];
        [self.color2 makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).offset(8 + 4 * 2 + 30);
            make.left.equalTo(self.left).offset(8);
            
        }];
        [self.color3 makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).offset(8 + 4 * 2 + 30 * 2);
            make.left.equalTo(self.left).offset(8);
            
        }];
        [self.color4 makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).offset(8 + 4 * 2 + 30 * 3);
            make.left.equalTo(self.left).offset(8);
            
        }];
        [self.color5 makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.top).offset(8 + 4 * 2 + 30 * 4);
            make.left.equalTo(self.left).offset(8);
            
        }];
    }
    return self;
}


@end

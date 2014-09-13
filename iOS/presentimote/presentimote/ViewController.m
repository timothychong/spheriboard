//
//  ViewController.m
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import "ViewController.h"
#import "ScratchPadLineView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton * leftButton;
@property (weak, nonatomic) IBOutlet UIButton * rightButton;
@property (weak, nonatomic) IBOutlet UIButton * cameraButton;
@property (weak, nonatomic) IBOutlet ScratchPadView * view;
@property (weak, nonatomic) ScratchPadLineView * currentLine;

@property (nonatomic) NSMutableArray * pathArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.delegate = self;
    self.pathArray = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)scratchPadView:(ScratchPadView *) view touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    ScratchPadLineView * newLine = [[ScratchPadLineView alloc]initWithFrame:self.view.frame];
    
    [newLine addPointWithX:touchLocation.x andY:touchLocation.y];
    self.currentLine = newLine;
    [self.view addSubview:newLine];
    [self.pathArray addObject:newLine];
}

-(void)scratchPadView:(ScratchPadView *) view touchesMoved:(NSSet *) touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    [self.currentLine addPointWithX:touchLocation.x andY:touchLocation.y];
}

-(void)scratchPadView:(ScratchPadView *)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    [self.currentLine addPointWithX:touchLocation.x andY:touchLocation.y];
}

@end

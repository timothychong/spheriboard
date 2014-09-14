//
//  ViewController.m
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import "ARView.h"
#import "BoardViewController.h"
#import "ScratchPadLineView.h"
#import "OrientationSolver.h"
#import "global_header.h"
#import <SocketIOPacket.h>
#define MAS_SHORTHAND
#import <Masonry/Masonry.h>

@interface BoardViewController ()

@property (nonatomic) SocketIO *socketIO;

@property (weak, nonatomic) IBOutlet ScratchPadView * view;
@property (weak, nonatomic) ScratchPadLineView * currentLine;

@property (nonatomic) NSMutableArray * pathArray;
@property (nonatomic) OrientationSolver * orientationSolver;

@property (nonatomic) double cur_phi, cur_theta, cur_orientation;

@property (nonatomic) bool dont_collect;
@property (weak, nonatomic) IBOutlet UIButton *blackButton;
@property (weak, nonatomic) IBOutlet UIButton *blueButton;
@property (weak, nonatomic) IBOutlet UIButton *redButton;
@property (weak, nonatomic) IBOutlet UIButton *greenButton;
@property (weak, nonatomic) IBOutlet UIButton *purpleButton;
@property (weak, nonatomic) IBOutlet UIButton *orangeButton;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;


@property (nonatomic) char selectedColor;
@property (nonatomic) BOOL colorMenuIsOpen;

@end

@implementation BoardViewController

@synthesize timer;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.socketIO = [[SocketIO alloc]initWithDelegate:self];
    [self.socketIO connectToHost:SOCKET_HOST onPort:SOCKET_HOST_PORT];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.orientationSolver = [[OrientationSolver alloc ] init];
    self.orientationSolver.delegate = self;
    self.view.delegate = self;
    self.pathArray = [NSMutableArray new];
    
    self.dont_collect = false;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(displayAll) userInfo:nil repeats:YES];
    [self.backgroundView makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@370);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self hideColorButtons: self.blackButton];
    
}

-(void) hideColorButtons:(id) sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.redButton.frame = CGRectMake(10, 8, 50, 50);
        self.redButton.alpha = 0;
        self.greenButton.frame = CGRectMake(10, 8, 50, 50);
        self.greenButton.alpha = 0;
        self.blueButton.frame = CGRectMake(10, 8, 50, 50);
        self.blueButton.alpha = 0;
        self.orangeButton.frame = CGRectMake(10, 8, 50, 50);
        self.orangeButton.alpha = 0;
        self.purpleButton.frame = CGRectMake(10, 8, 50, 50);
        self.purpleButton.alpha = 0;
        self.blackButton.alpha = 0;
        [self.backgroundView updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@70);
        }];
        ((UIView*)sender).alpha = 100;
    }];
    self.colorMenuIsOpen = NO;
}

-(void) showColorButtons{
    [UIView animateWithDuration:0.3 animations:^{
        self.redButton.frame = CGRectMake(10, 124, 50, 50);
        self.redButton.alpha = 100;
        self.greenButton.frame = CGRectMake(10, 182, 50, 50);
        self.greenButton.alpha = 100;
        self.blueButton.frame = CGRectMake(10, 66, 50, 50);
        self.blueButton.alpha = 100;
        self.orangeButton.frame = CGRectMake(10, 240, 50, 50);
        self.orangeButton.alpha = 100;
        self.purpleButton.frame = CGRectMake(10, 298, 50, 50);
        self.purpleButton.alpha = 100;
        self.blackButton.alpha = 100;
        [self.backgroundView updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@370);
        }];
    }];
    self.colorMenuIsOpen = YES;
}

-(IBAction)colorButtonClicked:(id)sender {
    
    if (self.colorMenuIsOpen) {
        if (sender == self.blackButton) {
            self.selectedColor = 0;
        } else if (sender == self.blueButton) {
            self.selectedColor = 1;
        } else if (sender == self.redButton) {
            self.selectedColor = 2;
        } else if (sender == self.greenButton) {
            self.selectedColor = 3;
        } else if (sender == self.orangeButton) {
            self.selectedColor = 4;
        } else if (sender == self.purpleButton) {
            self.selectedColor = 5;
        }
        [self hideColorButtons: sender];
    }else {
        [self showColorButtons];
    }
    
}


-(void)scratchPadView:(ScratchPadView *) view touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
    if (CGRectContainsPoint( self.leaveButton.frame , touchLocation)) {
        if (CGRectContainsPoint(self.quitButton.frame, touchLocation)) {
            [self leaveChannel:nil];
        } else if (CGRectContainsPoint(self.eraseButton.frame, touchLocation)) {
            [self erase:nil];
        } else if (CGRectContainsPoint(self.cameraButton.frame, touchLocation)){
            [self camera:nil];
        }
        
        return;
        
    }
    
    ScratchPadLineView * newLine = [[ScratchPadLineView alloc]initWithFrame:self.view.frame];
    newLine.color = self.selectedColor;
    newLine.delegate = self;
    
    [newLine addPointWithX:touchLocation.x andY:touchLocation.y];
    self.currentLine = newLine;
    [self.view insertSubview:newLine belowSubview:self.leaveButton];
    [self.pathArray addObject:newLine];
    
    self.dont_collect = true;
}

-(void)scratchPadView:(ScratchPadView *) view touchesMoved:(NSSet *) touches withEvent:(UIEvent *)event{
    
    if (!self.currentLine) {
        return;
    }
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    [self.currentLine addPointWithX:touchLocation.x andY:touchLocation.y];
    
    self.dont_collect = true;
}

-(void)scratchPadView:(ScratchPadView *)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.currentLine) {
        return;
    }
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    [self.currentLine addPointWithX:touchLocation.x andY:touchLocation.y];
    ScratchPadLineView * lineView = self.currentLine;
    NSMutableArray * array = [[NSMutableArray alloc]initWithCapacity:lineView.tim_path_length];
    NSNumber *myNumber = [NSNumber numberWithInt:[lineView getColor]];
    for( int i = 0; i < self.currentLine.tim_path_length; i++) {
        CGPoint point = [lineView getPathAtIndex:i];
        NSDictionary * dict = @{
                                @"x" : [NSNumber numberWithFloat:point.x],
                                @"y" : [NSNumber numberWithFloat:point.y],
                                };
        [array addObject:dict];
        
    }
    [self.socketIO sendEvent:@"savedrawing" withData: @{@"points":array, @"color":myNumber}];
    self.dont_collect = false;
    self.currentLine = nil;
}

-(void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"Receiving packet");
    
    NSError *error = nil;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [packet.data dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
   
    if (!error) {
        NSString * name = (NSString*)JSON[@"name"];
        if ([name isEqualToString:SOCKET_EVENT_NAME_DRAWING]) {
            NSDictionary * args = JSON[@"args"][0];
            NSArray * points = args[@"points"];
            char color = (char) ((NSNumber *)args[@"color"]).floatValue;
            ScratchPadLineView * newLine = [[ScratchPadLineView alloc]initWithFrame:self.view.frame];
            newLine.delegate = self;
            newLine.color = color;
            for (NSDictionary * dict in points) {
                float x = ((NSNumber *)dict[@"x"]).floatValue;
                float y = ((NSNumber *)dict[@"y"]).floatValue;
                NSLog(@"%f %f", x, y);
                [newLine addPointWithDBX:x andY:y];
            }
            [self.view insertSubview:newLine belowSubview:self.leaveButton];
            [self.pathArray addObject:newLine];
        } else if ([name isEqualToString:SOCKET_EVENT_NAME_DRAWING_ERASED]) {
            for (UIView * view in self.pathArray) {
                [view removeFromSuperview];
            }
            self.pathArray = [NSMutableArray new];
        }
    } else {
        NSLog(@"Erorr trying to convert packet from packet.data to an nsdictionary");
    }
}

-(void)socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"%@ socket connected.", socket);
    
    NSMutableString * uid = [NSMutableString new];
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    [uid setString:[oNSUUID UUIDString]];
    
    [self.socketIO sendEvent:@"subscribe" withData:@{@"uid": uid, @"channel" : self.roomCode}];
}

-(void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"SocketIO error: %@", error);
}
-(void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - OrientationSolver

-(void)OrientationSolver:(OrientationSolver *)solver didReceiveNewAccelerometerDataWithTheta:(double)theta andPhi:(double)phi andOrientation:(double)orientation
{
    if (!self.dont_collect) {
        self.cur_theta = theta;
        self.cur_phi = phi;
        self.cur_orientation = orientation;
    }
}

- (void)displayAll {
    for( ScratchPadLineView * path in self.pathArray) {
        [path setNeedsDisplay];
    }
}


#pragma mark - ScratchPadLineViewDelegate
-(void)scratchPadLineView:(ScratchPadLineView *)view currentPhi:(double *)phi currentTheta:(double *)theta currentOrientiation:(double *)orientation
{
    *phi = self.cur_phi;
    *theta = self.cur_theta;
    *orientation = self.cur_orientation;
}

#pragma mark - buttons

- (IBAction)leaveChannel:(id)sender {
    [self.socketIO disconnect];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)erase:(id)sender {
    UIActionSheet * sheet = [[UIActionSheet alloc]initWithTitle:@"Are you sure you want to remove everything in sphere?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil, nil];
    
    [sheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.socketIO sendEvent:@"erasedrawing" withData: @{}];
        for (UIView * view in self.pathArray) {
            [view removeFromSuperview];
        }
        self.pathArray = [NSMutableArray new];
    }
}



- (IBAction)camera:(id)sender {
}

- (IBAction)random:(id)sender {
}


@end

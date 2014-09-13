//
//  ViewController.m
//  presentimote
//
//  Created by Timothy Chong on 9/13/14.
//  Copyright (c) 2014 Downtyne. All rights reserved.
//

#import "ViewController.h"
#import "ScratchPadLineView.h"
#import "OrientationSolver.h"
#import "global_header.h"
#import <SocketIOPacket.h>

@interface ViewController ()

@property (nonatomic) SocketIO *socketIO;

@property (weak, nonatomic) IBOutlet ScratchPadView * view;
@property (weak, nonatomic) ScratchPadLineView * currentLine;

@property (nonatomic) NSMutableArray * pathArray;
@property (nonatomic) OrientationSolver * orientationSolver;

@property (nonatomic) double cur_phi, cur_theta, cur_orientation;

@property (nonatomic) bool dont_collect;

@end

@implementation ViewController

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)scratchPadView:(ScratchPadView *) view touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    ScratchPadLineView * newLine = [[ScratchPadLineView alloc]initWithFrame:self.view.frame];
    newLine.delegate = self;
    
    [newLine addPointWithX:touchLocation.x andY:touchLocation.y];
    self.currentLine = newLine;
    [self.view addSubview:newLine];
    [self.pathArray addObject:newLine];
    
    self.dont_collect = true;
}

-(void)scratchPadView:(ScratchPadView *) view touchesMoved:(NSSet *) touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    [self.currentLine addPointWithX:touchLocation.x andY:touchLocation.y];
    
    self.dont_collect = true;
}

-(void)scratchPadView:(ScratchPadView *)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    [self.currentLine addPointWithX:touchLocation.x andY:touchLocation.y];
    
    self.dont_collect = false;
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
            ScratchPadLineView * newLine = [[ScratchPadLineView alloc]initWithFrame:self.view.frame];
            newLine.delegate = self;
            for (NSDictionary * dict in points) {
                float x = ((NSNumber *)dict[@"x"]).floatValue;
                float y = ((NSNumber *)dict[@"y"]).floatValue;
                NSLog(@"%f %f", x, y);
                [newLine addPointWithDBX:x andY:y];
            }
            [self.view addSubview:newLine];
            [self.pathArray addObject:newLine];
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
    
    [self.socketIO sendEvent:@"subscribe" withData:@{@"uid": uid, @"channel" : @"testing"}];
}

-(void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"SocketIO error: %@", error);
}

#pragma mark - OrientationSolver

-(void)OrientationSolver:(OrientationSolver *)solver didReceiveNewAccelerometerDataWithTheta:(double)theta andPhi:(double)phi andOrientation:(double)orientation
{
    if (!self.dont_collect) {
        self.cur_theta = theta;
        self.cur_phi = phi;
        self.cur_orientation = orientation;
    }
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
@end

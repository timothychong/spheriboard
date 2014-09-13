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

@property (weak, nonatomic) IBOutlet UIButton * leftButton;
@property (weak, nonatomic) IBOutlet UIButton * rightButton;
@property (weak, nonatomic) IBOutlet UIButton * cameraButton;
@property (weak, nonatomic) IBOutlet ScratchPadView * view;
@property (weak, nonatomic) ScratchPadLineView * currentLine;

@property (nonatomic) NSMutableArray * pathArray;
@property (nonatomic) OrientationSolver * orientationSolver;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.socketIO = [[SocketIO alloc]init];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.orientationSolver = [[OrientationSolver alloc ] init];
    self.view.delegate = self;
    self.pathArray = [NSMutableArray new];
    self.socketIO = [[SocketIO alloc]initWithDelegate:self];
    self.socketIO.useSecure = NO;
    [self.socketIO connectToHost:SOCKET_HOST onPort:SOCKET_HOST_PORT];
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

-(void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSLog(@"Receiving packet");
    
    NSError *error = nil;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [packet.data dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &error];
   
    if (!error) {
        NSString * name = (NSString*)JSON[@"name"];
        if ([name isEqualToString:SOCKET_EVENT_NAME_DRAWING]) {
            NSLog(@"Socket received drawing");
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
    
    NSLog(@"%@", uid);
    [self.socketIO sendEvent:@"subscribe" withData:@{@"uid": uid, @"channel" : @"testing"}];
}

-(void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    NSLog(@"SocketIO error: %@", error);
}

@end

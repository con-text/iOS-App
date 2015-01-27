//
//  ViewController.m
//  Auth
//
//  Created by Denis Ogun on 27/01/2015.
//  Copyright (c) 2015 Context. All rights reserved.
//

#import "ViewController.h"
@import CoreBluetooth;
#import "Constants.h"

@interface ViewController () <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.peripheralManager = [[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    self.peripheralManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CBCentralMangerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"Powered off");
            break;
            
        case CBPeripheralManagerStatePoweredOn:
            self.peripheralManager startAdvertising:@{
            
        default:
            break;

    }
}



@end

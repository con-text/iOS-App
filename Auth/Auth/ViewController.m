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
@property (nonatomic, strong) CBMutableCharacteristic *key;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    self.peripheralManager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPeripheral
{
    /* Profile structure:
        - UserID
        - NoNcE field
        - Writeable Key
     */
    CBMutableCharacteristic *userDeviceID = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:IDENTITY_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyRead value:[@"User-5" dataUsingEncoding:NSUTF8StringEncoding] permissions:CBAttributePermissionsReadable];
    CBMutableCharacteristic *nonce = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:NONCE_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
    self.key = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:KEY_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    CBMutableService *userservice = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:IDENTITY_SERVICE_UUID
                                                                            ] primary:YES];
    
    // Add the characteristic to the serivce
    userservice.characteristics = @[userDeviceID, nonce, self.key];
    // Add the service to the peripheral
    [self.peripheralManager addService:userservice];
}

#pragma mark - CBCentralMangerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"Powered off");
            break;
            
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"Powered on");
            [self setupPeripheral];
            [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:IDENTITY_SERVICE_UUID]]}];
            break;
            
            
        default:
            break;

    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"Advertising with error: %@", [error localizedDescription]);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Added service with error: %@", [error localizedDescription]);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    for (CBATTRequest *request in requests) {
        if ([request.characteristic.UUID.UUIDString isEqualToString:NONCE_CHARACTERISTIC_UUID]) {
            NSString *nonceValue = [NSString stringWithUTF8String:[request.value bytes]];
            NSLog(@"Got a write value of %@", nonceValue);
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"Received read request %@", request);
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    
    NSString *tempKey = @"MIIBCgKCAQEA+xGZ/wcz9ugFpP07Nspo6U17l0YhFiFpxxU4pTk3Lifz9R3zsIsuERwta7+fWIfxOo208ett/jhskiVodSEt3QBGh4XBipyWopKwZ93HHaDVZAALi/2A+xTBtWdEo7XGUujKDvC2/aZKukfjpOiUI8AhLAfjmlcD/UZ1QPh0mHsglRNCmpCwmwSXA9VNmhz+PiB+Dml4WWnKW/VHo2ujTXxq7+efMU4H2fny3Se3KYOsFPFGZ1TNQSYlFuShWrHPtiLmUdPoP6CV2mML1tk+l7DIIqXrQhLUKDACeM5roMx0kLhUWB8P+0uj1CNlNN4JRZlC7xFfqiMbFRU9Z4N6YwIDAQAB";
    NSData *keyData = [tempKey dataUsingEncoding:NSASCIIStringEncoding];
    [self.peripheralManager updateValue:keyData forCharacteristic:self.key onSubscribedCentrals:nil];
}

@end

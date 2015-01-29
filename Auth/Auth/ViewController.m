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
@property (nonatomic, strong) NSData *keyToSend;
@property (nonatomic, assign) NSInteger sendDataIndex;
@property (nonatomic, assign) BOOL sendingEOM;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextbox;
@property (weak, nonatomic) IBOutlet UIButton *startAdvertisingButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    self.peripheralManager.delegate = self;
    self.startAdvertisingButton.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPeripheral
{
    // Reset and get the new username
    [self.peripheralManager removeAllServices];

    // Get the username
    NSString *username = [self.usernameTextbox.text isEqualToString:@""] ? @"Test-User" : self.usernameTextbox.text;
    
    /* Profile structure:
     - UserID
     - NoNcE field
     - Writeable Key
     */
    CBMutableCharacteristic *userDeviceID = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:IDENTITY_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyRead value:[username dataUsingEncoding:NSUTF8StringEncoding] permissions:CBAttributePermissionsReadable];
    CBMutableCharacteristic *nonce = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:NONCE_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyWriteWithoutResponse value:nil permissions:CBAttributePermissionsWriteable];
    self.key = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:KEY_CHARACTERISTIC_UUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    CBMutableService *userservice = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:IDENTITY_SERVICE_UUID
                                                                            ] primary:YES];
    
    // Add the characteristic to the serivce
    userservice.characteristics = @[userDeviceID, nonce, self.key];
    // Add the service to the peripheral
    [self.peripheralManager addService:userservice];
}

- (IBAction)toggleAdvertising:(id)sender
{
    if (self.peripheralManager.isAdvertising == TRUE) {
        [self.peripheralManager stopAdvertising];
    } else {
        [self setupPeripheral];
        NSDictionary *advertisingDictionary = @{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:IDENTITY_SERVICE_UUID]]};
        [self.peripheralManager startAdvertising:advertisingDictionary];
    }
}

#pragma mark - CBCentralMangerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOff:
            NSLog(@"Powered off");
            self.startAdvertisingButton.enabled = NO;
            break;
            
        case CBPeripheralManagerStateResetting:
            NSLog(@"Bluetooth resetting");
            self.startAdvertisingButton.enabled = NO;
            break;
            
        case CBPeripheralManagerStateUnauthorized:
            NSLog(@"Bluetooth unauthorized");
            self.startAdvertisingButton.enabled = NO;
            break;
            
        case CBPeripheralManagerStateUnknown:
            NSLog(@"Unknown state");
            self.startAdvertisingButton.enabled = NO;
            break;
            
        case CBPeripheralManagerStateUnsupported:
            NSLog(@"Bluetooth unsupported");
            self.startAdvertisingButton.enabled = NO;
            break;
        
        case CBPeripheralManagerStatePoweredOn:
            NSLog(@"Powered on");
            self.startAdvertisingButton.enabled = YES;
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
    NSLog(@"Maximum update length %lu", central.maximumUpdateValueLength);
    
    NSString *tempKey = @"MIIBCgKCAQEA+xGZ/wcz9ugFpP07Nspo6U17l0YhFiFpxxU4pTk3Lifz9R3zsIsuERwta7+fWIfxOo208ett/jhskiVodSEt3QBGh4XBipyWopKwZ93HHaDVZAALi/2A+xTBtWdEo7XGUujKDvC2/aZKukfjpOiUI8AhLAfjmlcD/UZ1QPh0mHsglRNCmpCwmwSXA9VNmhz+PiB+Dml4WWnKW/VHo2ujTXxq7+efMU4H2fny3Se3KYOsFPFGZ1TNQSYlFuShWrHPtiLmUdPoP6CV2mML1tk+l7DIIqXrQhLUKDACeM5roMx0kLhUWB8P+0uj1CNlNN4JRZlC7xFfqiMbFRU9Z4N6YwIDAQAB";
    
    // Store the key we send and reset the index
    self.keyToSend = [tempKey dataUsingEncoding:NSASCIIStringEncoding];
    self.sendDataIndex = 0;
    self.sendingEOM = NO;
    
    [self sendDataWithMTU:central.maximumUpdateValueLength];
}

- (void)sendDataWithMTU:(NSInteger)MTUValue
{
    static const char EOTBytes[] = "\x04";
    static const size_t EOTLength = sizeof(EOTBytes) - 1;
    
    // Send the EOM so the central knows all our data has been sent
    if (self.sendingEOM) {
        
        BOOL didSend = [self.peripheralManager updateValue:[NSData dataWithBytes:EOTBytes length:EOTLength] forCharacteristic:self.key onSubscribedCentrals:nil];
        
        if (didSend) {
            self.sendingEOM = NO;
            NSLog(@"Sent the EOM message");
        }
        
        return;
    }
    
    // There's no more data to send
    if (self.sendDataIndex >= self.keyToSend.length) {
        return;
    }
    
    // Loop until we've sent all the data
    BOOL didSend = YES;
    
    while (didSend) {
        NSInteger amountToSend = self.keyToSend.length - self.sendDataIndex;
        
        // We can't send more than the MTU size
        if (amountToSend > MTUValue) {
            amountToSend = MTUValue;
        }
        
        // Copy the data chunk we want to send
        NSData *dataChunk = [NSData dataWithBytes:self.keyToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send this chunk
        didSend = [self.peripheralManager updateValue:dataChunk forCharacteristic:self.key onSubscribedCentrals:nil];
        
        if (didSend == NO) {
            return;
        }
        
        // Print out what we've sent
        NSString *stringFromData = [[NSString alloc] initWithData:dataChunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent chunk: %@", stringFromData);
        
        // It sent so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last packet that we need to send
        if (self.sendDataIndex >= self.keyToSend.length) {
            
            // Send the EOM
            self.sendingEOM = YES;
            
            BOOL EOMSent = [self.peripheralManager updateValue:[NSData dataWithBytes:EOTBytes length:EOTLength] forCharacteristic:self.key onSubscribedCentrals:nil];
            
            if (EOMSent) {
                self.sendingEOM = NO;
                
                NSLog(@"Sent the EOM message");
            }
            
            return;
        }
    }
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Hard coded at this point, assuming we're only connected to one device
    [self sendDataWithMTU:101];
}

@end

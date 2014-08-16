//
//  AppDelegate.h
//  BLcentral-OSC2
//
//  Created by tani on 2014/08/08.
//  Copyright (c) 2014年 tani. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>
#include "lo/lo.h"

#define TM_INTERVAL 300 //

#define SEND_TO_IP "192.168.0.2"
#define SEND_TO_PORT "3001"


//@interface AppDelegate : NSObject <NSApplicationDelegate>

@interface AppDelegate : NSObject <NSApplicationDelegate,
    CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *manager;
    CBPeripheral *testPeripheral; // Peripheral
    
    lo_address* t;
    NSString* sendToPort;
    
    NSMutableArray *thermometers;
    BOOL autoConnect;
}

- (void) startScan;
- (void) stopScan;
- (BOOL) isLECapableHardware;

@property (assign) IBOutlet NSWindow *window;
@property (retain) NSMutableArray *thermometers;

@end

//
//  AppDelegate.h
//  BLcentral-OSC2
//
//  Created by tani on 2014/08/08.
//  Copyright (c) 2014年 tani. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>

//@interface AppDelegate : NSObject <NSApplicationDelegate>

@interface AppDelegate : NSObject <NSApplicationDelegate,
    CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *manager;
    CBPeripheral *testPeripheral; // Peripheral
    BOOL autoConnect;
}

- (void) startScan;
- (void) stopScan;
//- (BOOL) isLECapableHardware;

@property (assign) IBOutlet NSWindow *window;

@end

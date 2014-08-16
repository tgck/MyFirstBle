//
//  AppDelegate.m
//  BLcentral-OSC2
//
//  Created by tani on 2014/08/08.
//  Copyright (c) 2014年 tani. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSLog(@"- applicationDidFinishLaunching:aNotification");
}

#pragma mark - Start/Stop Scan methods
/*
 Request CBCentralManager to scan for health thermometer peripherals using service UUID 0x1809
 ペリフェラルのスキャン開始
 */
- (void)startScan
{
    NSLog(@"startScan");
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:FALSE], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    //    [manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"1809"]] options:options];
    [manager scanForPeripheralsWithServices:nil options:options];
}
/*
 Request CBCentralManager to stop scanning for health thermometer peripherals
 */
- (void)stopScan
{
    NSLog(@"stopScan");
    
    [manager stopScan];
}



#pragma mark - CBManagerDelegate methods
/*
 Invoked whenever the central manager's state is updated.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"- centralManagerDidUpdateState");
    
    //[self isLECapableHardware];
}

/*
 Invoked when the central discovers thermometer peripheral while scanning.
 スキャンにてペリフェラルを発見した時に呼ばれるメソッド
 */
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSLog(@"- centralManager:didDiscoverPeripheral:advertisementData:RSSI");
}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 セントラル・マネージャが、既知のペリフェラルの一覧を取得した時に、呼び出されます。
 この中でスキャンを終了し、特定のペリフェラルと接続試行する
 */
- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"- centralManager:didRetrievePeripherals"); // tani
}

/*
Invoked whenever a connection is succesfully created with the peripheral.
Discover available services on the peripheral
3) ペリフェラルとセントラルで接続確立した時によばれるメソッド
*/
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"- centralManager:didConnectPeripheral !!!");
    // [追加]信号強度の取得
}

// readRSSIにより呼ばれるデリゲートオブジェクトのメソッド
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral
                          error:(NSError *)error;
{
    NSLog(@"<- invoking peripheralDidUpdateRSSI");
    
    NSString* gotRSSI = [peripheral.RSSI stringValue];
    NSLog(@"<--- peripheralDidUpdateRSSI... %@", gotRSSI);
    
    // ブロックしているperipheral readRSSIを再開させるため、フラグを倒す
    //    self.finished = YES;
    
    // loop!!!!!
    //    sleep(3);
    usleep(500000); // 500msec間隔
    NSLog(@"-> calling readRSSI");
    [peripheral readRSSI];
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 ※ 接続解除時に呼ばれるメソッド
 ※なぜかこれが呼ばれる。
 */
- (void) centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                  error:(NSError *)error
{
    NSLog(@"- centralManager:didDisconnectPeripheral:error"); // tani
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 ※ 接続失敗時に呼び出されるメソッド
 */
- (void)    centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                     error:(NSError *)error
{
    NSLog(@"- centralManager:didFailToConnectPeripheral:error"); // tani
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// 主なユーザロジック (未実装)
//
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

@end

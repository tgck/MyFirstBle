//
// LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
// LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
// LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
// 3001

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize thermometers;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSLog(@"- applicationDidFinishLaunching:aNotification");

    
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    NSLog(@"args %d", (unsigned long)[arguments count]);
    for (NSString *str in arguments){
        NSLog(@"arg: %@", str);
    }
    
    // OSC送信先ポートの設定
    // コマンドライン起動の場合は、起動時引数を、
    // Xcodeからの起動の場合は、define値を使う。
    if ((unsigned long)[arguments count] == 2) {
        sendToPort = arguments[1];
    } else {
        sendToPort = @SEND_TO_PORT;
    }
    NSLog(@"sendToPort:%@", sendToPort);
        
    // 管理対象リスト初期化
    self.thermometers = [NSMutableArray array];
    
    // Managerを作成.作成直後ではmanagerが無効なので、state updateされることを待ってscan開始する。
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    
    // liblo setup
//    lo_address t = lo_address_new(NULL, "3001");
//    t = lo_address_new(NULL, SEND_TO_PORT);
//    t = lo_address_new(SEND_TO_IP, sendToPort);
    t = lo_address_new(SEND_TO_IP, "3001");
    lo_send(t, "/foo/bar", "ff", 0.12345678f, 24.0f);
}

- (void) dealloc
{
    NSLog(@"dealloc");
    [self stopScan];
    
    [testPeripheral setDelegate:nil];
    [testPeripheral release];
    
    [thermometers release];
    
    [manager release];
    
    [super dealloc];
}

/*
 Disconnect peripheral when application terminate
 */
- (void) applicationWillTerminate:(NSNotification *)notification
{
    NSLog(@"applicationWillTerminate");
    if(testPeripheral)
    {
        [manager cancelPeripheralConnection:testPeripheral];
    }
}

#pragma mark - LE Capable Platform/Hardware check
- (BOOL) isLECapableHardware
{
    NSLog(@"- isLECapableHardware"); // tani

    NSString * state = nil;
    
    switch ([manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            NSLog(@"%@", state);
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            NSLog(@"%@", state);
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            NSLog(@"%@", state);
            break;
        case CBCentralManagerStatePoweredOn:
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            NSLog(@"default" );
            return FALSE;
    }
    
    NSLog(@"Central manager state: %@", state);
    return FALSE;
}

#pragma mark - Start/Stop Scan methods

/*
 ペリフェラルのスキャン開始
 */
- (void)startScan
{
    NSLog(@"startScan");
    
    // TODO:
    //  UUIDの指定
    //
    
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
 managerのステータス監視。BL readyであることをチェックした上でスキャン開始する
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"- centralManagerDidUpdateState");
    
    if ([self isLECapableHardware]){
        [self startScan ];
    } else {
        NSLog(@"ERROR: !isLECapableHardware");
    }
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

    NSLog(@"Did discover peripheral.\n -peripheral: %@ \n -rssi: %@, \n -UUID: %@ \n -advertisementData: %@ ", peripheral, RSSI, peripheral.UUID, advertisementData);
    
    // 発見したperipheralを監視下に置く。操作対象のペリフェラルに登録
    NSMutableArray *peripherals = [self mutableArrayValueForKey:@"thermometers"];
    if( ![self.thermometers containsObject:peripheral] ){
        NSLog(@"added");
        [peripherals addObject:peripheral];
    }
  
    [self stopScan];
//    [manager retrievePeripherals:[NSArray arrayWithObject:(id)peripheral.UUID]];
    
    
    // 接続メソッド
    [self stopScan];
    if(true)
    {
        // NSIndexSet *indexes = [self.arrayController selectionIndexes];
//        if ([indexes count] != 0)
//        {
//            NSUInteger anIndex = [indexes firstIndex];
            NSUInteger anIndex = 0;
            testPeripheral = [self.thermometers objectAtIndex:anIndex];
            [testPeripheral retain];
//            [progressIndicator setHidden:FALSE];
//            [progressIndicator startAnimation:self];
//            [connectButton setTitle:@"Cancel"];
            [manager connectPeripheral:testPeripheral options:nil];
 //       }
    }
    
    
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

    NSLog(@"Retrieved peripheral: %lu - %@", [peripherals count], peripherals);
    [self stopScan];
}

/*
Invoked whenever a connection is succesfully created with the peripheral.
Discover available services on the peripheral
3) ペリフェラルとセントラルで接続確立した時によばれるメソッド
 そのままユーザロジックに流用。
*/
- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"- centralManager:didConnectPeripheral");
    NSLog(@"INFO    :connection started to the peripheral");

    // ペリフェラルとのやり取りを始める前に、当該ペリフェラルのデリゲートを設定
    [peripheral setDelegate:self];
    
    sleep(3);
    
    // [追加]信号強度の取得
    NSLog(@"start to get RSSI in loop");
    [peripheral readRSSI];
    
    // ここには到達しない..
    NSLog(@"debug!");
}

// readRSSIにより呼ばれるデリゲートオブジェクトのメソッド
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral
                          error:(NSError *)error;
{
    NSLog(@"<- invoking peripheralDidUpdateRSSI");
    
    NSString* gotRSSI = [peripheral.RSSI stringValue];
    NSLog(@"<--- peripheralDidUpdateRSSI... %@", gotRSSI);
    
    int rssi = [gotRSSI integerValue];
//    lo_send();
    lo_send(t, "/rssi", "i", rssi);
    
    usleep(TM_INTERVAL * 1000);
    
    NSLog(@"-> calling readRSSI");
    [peripheral readRSSI];
}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 ※ 接続解除時に呼ばれる、デリゲートオブジェクトのメソッド
 */
- (void) centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                  error:(NSError *)error
{
    NSLog(@"- centralManager:didDisconnectPeripheral:error"); // tani
    NSLog(@"INFO    :connection ended to the peripheral");
    
    // TODO:
    // ここで再接続する？
    //
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

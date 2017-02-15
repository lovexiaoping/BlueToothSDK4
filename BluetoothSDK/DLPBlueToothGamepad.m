//
//  DLPBlueToothGamepad.m
//  BabyBluetoothAppDemo
//
//  Created by love_ping891122 on 2017/1/4.
//  Copyright © 2017年 刘彦玮. All rights reserved.
//

#import "DLPBlueToothGamepad.h"


#define CHCANNEL @"CharacteristicView"

#define SERVICE  @"FFF0"
#define CHARATIC @"FFF5"


@implementation DLPBlueToothGamepad

static DLPBlueToothGamepad *BlueToothGamepad;

+ (instancetype)sharedInstanceDLPBlueToothGamepad
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BlueToothGamepad = [[self alloc] init];
    });
    
    return BlueToothGamepad;
}


#pragma mark -蓝牙配置和操作

-(void)startDLPBlueToothGamepad{
    
    
    
   
}
-(void)startlueToothGamepad
{
    baby = [BabyBluetooth shareBabyBluetooth];
    
    [self babyDelegate1];
    
    [self startScanningDevice];

}
//蓝牙网关初始化和委托方法设置
-(void)babyDelegate1{
    
    
    __weak typeof(self) weakSelf = self;
    
    [baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"设备打开成功，开始扫描设备"];
        }
    }];
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        [weakSelf responsePeripheral:peripheral
         
                   advertisementData:advertisementData];
    }];
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        NSLog(@"有几个服务 :%ld",peripheral.services.count);
        
        for (CBService *service in peripheral.services) {
            //搜索到该peripheral所有服务
            NSLog(@"该服务的UUID :%@",service.UUID.UUIDString);
        }
        
    }];
    //设置查找设备的过滤器
    [baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        //最常用的场景是查找某一个前缀开头的设备
        /*
         if ([peripheralName hasPrefix:@"Pxxxx"] ) {
         return YES;
         }
         return NO;
         */
        //名字
        NSString *localN = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
        
        //设置查找规则是名称大于0 ， the search rule is peripheral.name length > 0
        if (peripheralName.length >0) {
            return YES;
        }
        return NO;
    }];
    
    
    [baby setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        NSLog(@"取消All Peripherals连接");
    }];
    
    [baby setBlockOnCancelScanBlock:^(CBCentralManager *centralManager) {
        NSLog(@"取消扫描");
    }];
    
}

//开始扫描设备
-(void)startScanningDevice{
    
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [baby setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    baby.scanForPeripherals().begin();
    
    [SVProgressHUD showInfoWithStatus:@"开始扫描设备"];
    
    
}
//获取到所有搜到的Peripheral，匹配
-(void)responsePeripheral:(CBPeripheral *)peripheral

        advertisementData:(NSDictionary *)advertisementData{
    
    NSString *localN = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    
    if ([peripheral.name containsString:@"baby"]||
        [localN containsString:@"baby"]) {
        
        [SVProgressHUD showInfoWithStatus:@"搜索到包含baby的设备"];
        
        [self connectCurrPeripheral:peripheral];
    }
    
}
//开始连接该Peripheral
-(void)connectCurrPeripheral:(CBPeripheral*)Peripheral{
    //停止扫描
    [baby cancelScan];
    
    
    self.currPeripheral = Peripheral;
    
    [self babyDelegate2];
    
    [self startConnectP];
    
    
}

//开始连接设备
-(void)startConnectP{
    
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    baby.having(self.currPeripheral).and.channel(CHCANNEL).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}




#pragma mark ------------  第二步

//babyDelegate2
-(void)babyDelegate2{
    
    __weak typeof(self)weakSelf = self;
    
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [baby setBlockOnConnectedAtChannel:CHCANNEL block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
    }];
    
    //设置设备连接失败的委托
    [baby setBlockOnFailToConnectAtChannel:CHCANNEL block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
    }];
    
    //设置设备断开连接的委托
    [baby setBlockOnDisconnectAtChannel:CHCANNEL block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开失败",peripheral.name]];
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServicesAtChannel:CHCANNEL block:^(CBPeripheral *peripheral, NSError *error) {
        
        [rhythm beats];
    }];
    //设置发现设service的Characteristics的委托
    [baby setBlockOnDiscoverCharacteristicsAtChannel:CHCANNEL block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        
    }];
    
    
#pragma mark ---- 读取characteristics 值
    
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristicAtChannel:CHCANNEL block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        
        
    }];
    //设置发现characteristics的descriptors的委托
    [baby setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:CHCANNEL block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        
        if (![weakSelf isDuring])
        {
            
            for (CBService *s in peripheral.services) {
                NSLog(@"***4*** : %@",s.UUID.UUIDString);
                
                if ([s.UUID.UUIDString isEqual:SERVICE]) {
                    
                    [weakSelf responseService:s];
                    
                    break;
                }
            }
            
        }
        
        
        [rhythm beats];
        
    }];
    //设置读取Descriptor的委托
    [baby setBlockOnReadValueForDescriptorsAtChannel:CHCANNEL block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        
    }];
    
    
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [baby setBabyOptionsAtChannel:CHCANNEL scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

#pragma mark ------------  第三步

//发现找到characteristic委托
-(void)responseService:(CBService *)service{
    
    for (int row=0;row<service.characteristics.count;row++)
    {
        CBCharacteristic *c = service.characteristics[row];
        NSLog(@"%@",c.UUID.UUIDString);
        
        if ([c.UUID.UUIDString isEqual:CHARATIC]) {
            //约定的characteristic的UUID
            self.characteristic = c;
            [self babyDelegate2];
            //读取服务
            baby.channel(CHCANNEL).characteristicDetails(self.currPeripheral,self.characteristic);
            //订阅服务
            [self changeSateNotify];
        }
        
    }
}

//插入Notify读取的值
-(void)insertReadValues:(CBCharacteristic *)characteristics{
    
    NSData *data =   characteristics.value;
    if (![data isKindOfClass:[NSNull class]] &&data.length>0 ) {
        
        NSString *value_string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"订阅传输数据:%@",value_string);
        
        NSDictionary *info = @{@"KeyValue":value_string,
                               @"state":@1};
        [[NSNotificationCenter defaultCenter]postNotificationName:BLUETOOTHGAMEPADNOTIFY object:nil userInfo:info];
        
        [SVProgressHUD showErrorWithStatus:value_string];
        
    }
    
}

//订阅一个值
-(void)changeSateNotify{
    
    __weak typeof(self)weakSelf = self;
    if(self.currPeripheral.state != CBPeripheralStateConnected) {
        NSDictionary *info = @{@"KeyValue":@"",
                               @"state":@0};
        [[NSNotificationCenter defaultCenter]postNotificationName:BLUETOOTHGAMEPADNOTIFY object:nil userInfo:info];

        [SVProgressHUD showErrorWithStatus:@"peripheral已经断开连接，请重新连接"];
        return;
    }
    
    self.isDuring = YES;
    
    if (self.characteristic.properties & CBCharacteristicPropertyNotify ||  self.characteristic.properties & CBCharacteristicPropertyIndicate) {
        [SVProgressHUD showErrorWithStatus:@"订阅成功,可以开始传输数据"];
        NSDictionary *info = @{@"KeyValue":@"",
                               @"state":@2};
        [[NSNotificationCenter defaultCenter]postNotificationName:BLUETOOTHGAMEPADNOTIFY object:nil userInfo:info];
        //订阅开关
        if(self.characteristic.isNotifying)
        {
            [baby cancelNotify:self.currPeripheral characteristic:self.characteristic];
        }else{
            [weakSelf.currPeripheral setNotifyValue:YES forCharacteristic:self.characteristic];
            [baby notify:self.currPeripheral
          characteristic:self.characteristic
                   block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                       [self insertReadValues:characteristics];
                   }];
        }
    }
    else{
        [SVProgressHUD showErrorWithStatus:@"这个characteristic没有nofity的权限"];
    }
    
}


@end

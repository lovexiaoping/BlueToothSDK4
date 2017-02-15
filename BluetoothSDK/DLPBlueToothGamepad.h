//
//  DLPBlueToothGamepad.h
//  BabyBluetoothAppDemo
//
//  Created by love_ping891122 on 2017/1/4.
//  Copyright © 2017年 刘彦玮. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"

#import "SVProgressHUD.h"

#define BLUETOOTHGAMEPADNOTIFY @"BlueToothNotify"

@interface DLPBlueToothGamepad : NSObject{
    
    BOOL isDuring;
    
    BabyBluetooth *baby;
    
}
@property(assign,nonatomic)BOOL isDuring;

@property(strong,nonatomic)CBPeripheral *currPeripheral;

@property (nonatomic,strong)CBCharacteristic *characteristic;//特性

+ (instancetype)sharedInstanceDLPBlueToothGamepad;

-(void)startDLPBlueToothGamepad;

@end

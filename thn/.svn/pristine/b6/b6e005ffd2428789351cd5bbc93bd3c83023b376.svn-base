//
//  THNCartDB.m
//  store
//
//  Created by XiaobinJia on 14-11-12.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNCartDB.h"

#import <FMDB.h>

@implementation THNCartDB
{
    FMDatabase *_cartDB;
}

SYNTHESIZE_SINGLETON_FOR_CLASS(THNCartDB);

/*数据库路径*/
-(NSString *)CartDatabaseFilePath
{
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [docsDir stringByAppendingPathComponent:@"cart.sqlite"];
    JYLog(@"%@",dbPath);
    return dbPath;
}

-(void)creatCartDatabase
{
    _cartDB = [[FMDatabase databaseWithPath:[self CartDatabaseFilePath]] retain];
}

-(void)creatTable
{
    //先判断数据库是否存在，如果不存在，创建数据库
    if (!_cartDB) {
        [self creatCartDatabase];
    }
    //判断数据库是否已经打开，如果没有打开，提示失败
    if (![_cartDB open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    //为数据库设置缓存，提高查询效率
    [_cartDB setShouldCacheStatements:YES];
    
    //判断数据库中是否已经存在这个表，如果不存在则创建该表
    if(![_cartDB tableExists:@"product"])
    {
        /*id type count image title price*/
        NSString *createSql = @"CREATE TABLE IF NOT EXISTS product(\
        'key' INTEGER PRIMARY KEY autoincrement NOT NULL, \
        id TEXT, \
        type TEXT, \
        count TEXT, \
        image TEXT, \
        title TEXT, \
        price TEXT, \
        skuid integer\
        )";
        BOOL res = [_cartDB executeUpdate:createSql];
        if (!res) {
            JYLog(@"error when creating db table");
        } else {
            JYLog(@"succ to creating db table");
        }
    }
    
}

#pragma mark - API
-(int)addItem:(THNCartItem *)aItem;
{
    int ret = 0;
    if (!_cartDB) {
        [self creatCartDatabase];
    }
    
    if (![_cartDB open]) {
        NSLog(@"数据库打开失败");
        return ret;
    }
    
    [_cartDB setShouldCacheStatements:YES];
    
    if(![_cartDB tableExists:@"product"])
    {
        [self creatTable];
    }
    //以上操作与创建表是做的判断逻辑相同
    //现在表中查询有没有相同的元素，如果有，做修改操作
    FMResultSet *rs = [_cartDB executeQuery:@"select * from product where id = ? and skuid = ?",aItem.itemProduct.brief.productID, [NSNumber numberWithInt:aItem.itemProductSKUID]];

    if([rs next])
    {
        ret = 2;
    }
    //向数据库中插入一条数据
    else{
        BOOL retValue = [_cartDB executeUpdate:@"INSERT INTO product \
               (id, type, count, image, title, price, skuid) \
               VALUES (?,?,?,?,?,?,?)",aItem.itemProduct.brief.productID, aItem.itemProductSKUTitle, aItem.itemProductCount, aItem.itemProduct.brief.productImage, aItem.itemProduct.brief.productTitle, aItem.itemProductPrice, [NSNumber numberWithInt:aItem.itemProductSKUID]];
        ret=retValue?1:0;
    }
    [_cartDB close];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CartCountChange" object:nil];
    return ret;
}

-(void)deleteItem:(THNCartItem *)item
{
    if (!_cartDB) {
        [self creatCartDatabase];
    }
    
    if (![_cartDB open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    [_cartDB setShouldCacheStatements:YES];
    
    //判断表中是否有指定的数据， 如果没有则无删除的必要，直接return
    if(![_cartDB tableExists:@"product"])
    {
        return;
    }
    //删除操作
    [_cartDB executeUpdate:@"delete from product where id = ? and skuid = ?", item.itemProduct.brief.productID, [NSNumber numberWithInt:item.itemProductSKUID]];
    
    [_cartDB close];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CartCountChange" object:nil];
}

- (int)allCount
{
    NSArray *arr = [self allItem];
    return (int)[arr count];
}

- (NSArray *)allItem
{
    if (!_cartDB) {
        [self creatCartDatabase];
    }
    
    if (![_cartDB open]) {
        NSLog(@"数据库打开失败");
        return nil;
    }
    
    [_cartDB setShouldCacheStatements:YES];
    
    if(![_cartDB tableExists:@"product"])
    {
        return nil;
    }
    
    //定义一个可变数组，用来存放查询的结果，返回给调用者
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:0];
    //定义一个结果集，存放查询的数据
    FMResultSet *rs = [_cartDB executeQuery:@"select * from product"];
    //判断结果集中是否有数据，如果有则取出数据
    while ([rs next]) {
        THNCartItem *item = [[THNCartItem alloc] init];
        
        item.itemProduct.brief.productID = [rs stringForColumn:@"id"];
        item.itemProductCount = [rs stringForColumn:@"count"];
        item.itemProductSKUTitle = [rs stringForColumn:@"type"];
        item.itemProduct.brief.productImage = [rs stringForColumn:@"image"];
        item.itemProduct.brief.productTitle = [rs stringForColumn:@"title"];
        item.itemProductPrice = [rs stringForColumn:@"price"];
        item.itemProductSKUID = [rs intForColumn:@"skuid"];
        
        //将查询到的数据放入数组中。 
        [ret addObject:item];
        [item release];
    }
    [_cartDB close];
    return [ret autorelease];
}
- (void)deleteAll
{
    if (!_cartDB) {
        [self creatCartDatabase];
    }
    
    if (![_cartDB open]) {
        NSLog(@"数据库打开失败");
        return;
    }
    
    [_cartDB setShouldCacheStatements:YES];
    
    if(![_cartDB tableExists:@"product"])
    {
        return;
    }
    
    [_cartDB executeUpdate:@"DELETE FROM product"];
    [_cartDB executeUpdate:@"UPDATE sqlite_sequence set seq=0 where name='product'"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CartCountChange" object:nil];
}
@end

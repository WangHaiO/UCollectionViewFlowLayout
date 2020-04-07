//
//  ViewController.m
//  UCollectionViewFlowLayout
//
//  Created by HaiOu on 2020/4/7.
//  Copyright © 2020 HaiOu. All rights reserved.
//

#import "ViewController.h"
#import "UCollectionViewFlowLayout.h"

#define kCell @"kCell"
#define kHeaderFooter @"kHeaderFooter"

@interface ViewController ()<UICollectionViewDataSource, UCollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@end

@implementation ViewController{
    NSMutableArray *values;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configData];
    [self configUI];
}

- (void)configData {
    values = [NSMutableArray arrayWithCapacity:100];
    for (NSInteger idx = 0; idx != 100; idx++) {
        [values addObject:[NSNumber numberWithInteger:10 + (arc4random() % 101)]];
    }
}

- (void)configUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCell forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor greenColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                                                    withReuseIdentifier:kHeaderFooter
                                                                                                                           forIndexPath:indexPath];
    header.backgroundColor = [UIColor redColor];
    return header;
}

#pragma mark - UCollectionViewDelegateFlowLayout

/**
 动态设置item的高度
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout itemHeightForWidth:(CGFloat)itemWidth atIndexPath:(NSIndexPath *)indexPath {
    return [values[indexPath.item] floatValue];
}

/**
 每个区的列数
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnNumberAtSection:(NSInteger )section {
    return 5;
}

/**
 每个区的内边距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

/**
 每个区中行间距
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section {
    return 15;
}

/**
 每个区的列间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section {
    return 15.f;
}

/**
 设置section中对应的header视图的参考大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(self.view.bounds.size.width, 20);
}

/**
 设置section中对应的footer视图的参考大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(self.view.bounds.size.width, 20);
}

#pragma mark - lazyLoading

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UCollectionViewFlowLayout *flowLayout = [[UCollectionViewFlowLayout alloc] init];
        flowLayout.itemHeight = 30;
        flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        flowLayout.lineSpacing = 15.f;
        flowLayout.interitemSpacing = 15.f;
        flowLayout.delegate = self;
        flowLayout.isWaterfallsFlow = YES;
        flowLayout.sectionHeadersPinToVisibleBounds = YES;
        flowLayout.sectionFootersPinToVisibleBounds = YES;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCell];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeaderFooter];
    }
    return _collectionView;
}

@end

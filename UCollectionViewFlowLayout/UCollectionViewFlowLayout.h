//
//  UCollectionViewFlowLayout.h
//  mobile
//
//  Created by HaiOu on 2019/2/20.
//  Copyright © 2019 azazie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class UCollectionViewFlowLayout;

@protocol UCollectionViewDelegateFlowLayout <NSObject>
@optional

/**
 动态设置item的高度
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout itemHeightForWidth:(CGFloat)itemWidth atIndexPath:(NSIndexPath *)indexPath;
/**
 每个区的列数
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnNumberAtSection:(NSInteger )section;
/**
 每个区的内边距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
/**
 每个区中行间距
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout lineSpacingForSectionAtIndex:(NSInteger)section;
/**
 每个区的列间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout interitemSpacingForSectionAtIndex:(NSInteger)section;
/**
 设置section中对应的header视图的参考大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
/**
 设置section中对应的footer视图的参考大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

@end

@interface UCollectionViewFlowLayout : UICollectionViewLayout

@property (nonatomic, weak) id<UCollectionViewDelegateFlowLayout> delegate;
/** 列数 默认有两列*/
@property (nonatomic, assign) NSUInteger columnCount;
/** 行间距 */
@property (nonatomic, assign) CGFloat lineSpacing;
/** 列间距 */
@property (nonatomic, assign) CGFloat interitemSpacing;
@property (nonatomic, assign) CGFloat itemHeight;
@property (nonatomic) CGSize headerReferenceSize;
@property (nonatomic) CGSize footerReferenceSize;
@property (nonatomic) UIEdgeInsets sectionInset;

@property (nonatomic) BOOL sectionHeadersPinToVisibleBounds;
@property (nonatomic) BOOL sectionFootersPinToVisibleBounds;
/** 是否是瀑布流布局，默认是NO */
@property (nonatomic, assign) BOOL isWaterfallsFlow;

@end

NS_ASSUME_NONNULL_END

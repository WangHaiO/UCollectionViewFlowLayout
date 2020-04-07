//
//  UCollectionViewFlowLayout.m
//  mobile
//
//  Created by HaiOu on 2019/2/20.
//  Copyright © 2019 azazie. All rights reserved.
//

#import "UCollectionViewFlowLayout.h"

@interface UCollectionViewFlowLayout ()
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attributesHeaderArrm;
@property (nonatomic, strong) NSMutableArray<NSArray<UICollectionViewLayoutAttributes *> *> *attributesSectionArrm;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attributesFooterArrm;
/** 瀑布流布局 记录当前section每一列的高度 */
@property (nonatomic, strong) NSMutableArray *sectionColumnHeightArrm;
/** 记录当前section内容的高度 */
@property (nonatomic, assign) CGFloat sectionContentHeight;
@property (nonatomic, assign) CGFloat contentHeight;
@end

@implementation UCollectionViewFlowLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.attributesHeaderArrm = [NSMutableArray array];
        self.attributesSectionArrm = [NSMutableArray array];
        self.attributesFooterArrm = [NSMutableArray array];
        self.columnCount = 2;
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    [self.attributesHeaderArrm removeAllObjects];
    [self.attributesSectionArrm removeAllObjects];
    [self.attributesFooterArrm removeAllObjects];
    self.contentHeight = 0.f;
    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
    NSInteger sectionCount = [self.collectionView numberOfSections];
    
    for (NSInteger section = 0; section < sectionCount; section ++) {
        NSUInteger    columnCount;
        CGFloat       lineSpacing;
        CGFloat       interitemSpacing;
        CGFloat       itemHeight;
        CGSize        headerReferenceSize;
        CGSize        footerReferenceSize;
        UIEdgeInsets  sectionInset;
        // 列数
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:columnNumberAtSection:)]) {
            columnCount = [self.delegate collectionView:self.collectionView layout:self columnNumberAtSection:section];
        } else {
            columnCount = self.columnCount;
        }
        // 内间距
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        } else {
            sectionInset = self.sectionInset;
        }
        // 行距
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:lineSpacingForSectionAtIndex:)]) {
            lineSpacing = [self.delegate collectionView:self.collectionView layout:self lineSpacingForSectionAtIndex:section];
        } else {
            lineSpacing = self.lineSpacing;
        }
        // 列距
        if ([self.delegate  respondsToSelector:@selector(collectionView:layout:interitemSpacingForSectionAtIndex:)]) {
            interitemSpacing = [self.delegate collectionView:self.collectionView layout:self interitemSpacingForSectionAtIndex:section];
        } else {
            interitemSpacing = self.interitemSpacing;
        }
        // 区头
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
            headerReferenceSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
        } else {
            headerReferenceSize = self.headerReferenceSize;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathWithIndex:section];
        UICollectionViewLayoutAttributes *headerAttributs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
        headerAttributs.frame = CGRectMake(0.f,  self.contentHeight, headerReferenceSize.width, headerReferenceSize.height);
        [self.attributesHeaderArrm addObject:headerAttributs];
        self.contentHeight += headerReferenceSize.height;
        // 内间距的顶部
        if (self.isWaterfallsFlow){
            self.sectionColumnHeightArrm = [NSMutableArray arrayWithCapacity:columnCount];
            //添加区的顶部内间距
            for (NSInteger i = 0; i < columnCount; i++) {
                self.sectionColumnHeightArrm[i] = @(self.contentHeight + sectionInset.top);
            }
        } else {
            self.contentHeight += sectionInset.top;
            self.sectionContentHeight = 0.f;
        }
        // Item
        NSInteger itemCountOfSection = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *attributesArrm = [NSMutableArray arrayWithCapacity:itemCountOfSection];
        for (NSInteger item = 0; item < itemCountOfSection; item ++)
        {
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:item inSection:section];
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            // item的宽度 = (collectionView的宽度 - 内边距与列间距) / 列数
            CGFloat itemWidth = (collectionViewWidth - sectionInset.left - sectionInset.right - (columnCount - 1) * interitemSpacing) / columnCount;
            // item的高度
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:itemHeightForWidth:atIndexPath:)]) {
                itemHeight = [self.delegate collectionView:self.collectionView layout:self itemHeightForWidth:itemWidth atIndexPath:indexPath];
            } else {
                itemHeight = self.itemHeight;
            }
            CGFloat itemX = sectionInset.left;
            CGFloat itemY = 0.f;
            if (self.isWaterfallsFlow) {
                // 找出最短的那一列
                __block NSUInteger minIndex = 0;
                [self.sectionColumnHeightArrm enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([self.sectionColumnHeightArrm[minIndex] floatValue] > obj.floatValue) {
                        minIndex = idx;
                    }
                }];
                // 根据最短列的列数计算item的x值
                itemX = sectionInset.left + (interitemSpacing + itemWidth) * minIndex;
                // item的y值 = 最短列的最大y值 + 行间距
                if (indexPath.item/columnCount == 0) {
                    itemY = [self.sectionColumnHeightArrm[minIndex] floatValue];
                } else {
                    itemY = [self.sectionColumnHeightArrm[minIndex] floatValue] + lineSpacing;
                }
                // 更新字典中的最大y值
                self.sectionColumnHeightArrm[minIndex] = @(itemY + itemHeight);
            } else {
                itemX = sectionInset.left + indexPath.item % columnCount * (itemWidth + interitemSpacing);
                itemY = self.contentHeight + indexPath.item / columnCount * (lineSpacing + itemHeight);
                self.sectionContentHeight = itemY + itemHeight;
            }
            attributes.frame = CGRectMake(itemX, itemY, itemWidth, itemHeight);
            [attributesArrm addObject:attributes];
        }
        [self.attributesSectionArrm addObject:attributesArrm];
        if (self.isWaterfallsFlow) {
            // 遍历字典，找出最长的值
            __block CGFloat maxY = 0.f;
            [self.sectionColumnHeightArrm enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (maxY < obj.floatValue) {
                    maxY = obj.floatValue;
                }
            }];
            self.contentHeight = maxY;
        } else {
            self.contentHeight = self.sectionContentHeight;
        }
        // 内间距的底部
        self.contentHeight += sectionInset.bottom;
        // 区尾
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
            footerReferenceSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section];
        } else {
            footerReferenceSize = self.footerReferenceSize;
        }
        UICollectionViewLayoutAttributes *footerAttributs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:indexPath];
        footerAttributs.frame = CGRectMake(0.f, self.contentHeight, footerReferenceSize.width, footerReferenceSize.height);
        [self.attributesFooterArrm addObject:footerAttributs];
        self.contentHeight += footerReferenceSize.height;
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.attributesSectionArrm[indexPath.section][indexPath.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return self.attributesHeaderArrm[indexPath.section];
    } else {
        return self.attributesFooterArrm[indexPath.section];
    }
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.frame.size.width, self.contentHeight);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    /**
     *  返回当前显示区域的所有布局信息
     */
    NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributesArrm = [NSMutableArray array];
    [self.attributesHeaderArrm enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(obj.frame, rect)) {
            [layoutAttributesArrm addObject:obj];
        }
    }];
    [self.attributesSectionArrm enumerateObjectsUsingBlock:^(NSArray<UICollectionViewLayoutAttributes *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (CGRectIntersectsRect(obj.frame, rect)) {
                [layoutAttributesArrm addObject:obj];
            }
        }];
    }];
    [self.attributesFooterArrm enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(obj.frame, rect)) {
            [layoutAttributesArrm addObject:obj];
        }
    }];
    if (!self.sectionHeadersPinToVisibleBounds && !self.sectionFootersPinToVisibleBounds) {
        return layoutAttributesArrm;
    }
    
    /**
     *  header及footer的悬停处理
     */
    UICollectionView * const cv = self.collectionView;
    CGPoint const contentOffset = cv.contentOffset;
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    /**
     *  找出所有UICollectionElementCategoryCell类型的cell
     */
    [layoutAttributesArrm enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.representedElementCategory == UICollectionElementCategoryCell) {
            [missingSections addIndex:obj.indexPath.section];
        }
    }];
    if (self.sectionHeadersPinToVisibleBounds) {
        NSMutableIndexSet *missingSectionsHeader = [missingSections mutableCopy];
        /**
         *  再从里面删除所有UICollectionElementKindSectionHeader类型的cell
         */
        [layoutAttributesArrm enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
                [missingSectionsHeader removeIndex:obj.indexPath.section];
            }
        }];
        /**
         *  对rect外的Header生成attributes 加入Attributes数组
         */
        [missingSectionsHeader enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
            UICollectionViewLayoutAttributes *layoutAttributesHeader = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
            [layoutAttributesArrm addObject:layoutAttributesHeader];
        }];
    }
    if (self.sectionFootersPinToVisibleBounds) {
        NSMutableIndexSet *missingSectionsFooter = [missingSections mutableCopy];
        /**
         *  再从里面删除所有UICollectionElementKindSectionFooter类型的cell
         */
        [layoutAttributesArrm enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
                [missingSectionsFooter removeIndex:obj.indexPath.section];
            }
        }];
        /**
         *  对rect外的Footer生成attributes 加入Attributes数组
         */
        [missingSectionsFooter enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
            UICollectionViewLayoutAttributes *layoutAttributesFooter = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];
            [layoutAttributesArrm addObject:layoutAttributesFooter];
        }];
    }
    [layoutAttributesArrm enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull layoutAttributes, NSUInteger idx, BOOL * _Nonnull stop) {
        /**
         *  从layoutAttributesArr中储存的布局信息中，针对UICollectionElementKindSectionHeader...
         */
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader] && self.sectionHeadersPinToVisibleBounds)
        {
            NSInteger section = layoutAttributes.indexPath.section;
            NSInteger numberOfItemsInSection = [cv numberOfItemsInSection:section];
            
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            
            /**
             *  针对当前layoutAttributes的section， 找出第一个和最底部一个普通cell的位置
             */
            UICollectionViewLayoutAttributes *firstCellAttrs = [self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
            __block UICollectionViewLayoutAttributes *bottomCellAttrs;
            if (self.isWaterfallsFlow) {
                [self.attributesSectionArrm[section] enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (CGRectGetMaxY(bottomCellAttrs.frame) < CGRectGetMaxY(obj.frame)) {
                        bottomCellAttrs = obj;
                    }
                }];
            } else {
                NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
                bottomCellAttrs = [self layoutAttributesForItemAtIndexPath:lastCellIndexPath];
            }
            /**
             *  获取当前处理header的高度和位置，然后通过firstCellAttrs和bottomCellAttrs确定header是否置顶
             */
            CGFloat headerHeight = CGRectGetHeight(layoutAttributes.bounds);
            //内间距
            UIEdgeInsets sectionInset;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
                sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
            } else {
                sectionInset = self.sectionInset;
            }
            CGPoint origin = layoutAttributes.frame.origin;
            origin.y = MIN(
                           MAX(
                               contentOffset.y,
                               CGRectGetMinY(firstCellAttrs.frame) - sectionInset.top - headerHeight
                               ),
                           CGRectGetMaxY(bottomCellAttrs.frame) + sectionInset.bottom - headerHeight
                           );
            layoutAttributes.zIndex = 1024;
            layoutAttributes.frame = (CGRect){
                .origin = origin,
                .size = layoutAttributes.frame.size
            };
        }
        /**
         *  从layoutAttributesArr中储存的布局信息中，针对UICollectionElementKindSectionFooter...
         */
        else if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionFooter] && self.sectionFootersPinToVisibleBounds)
        {
            NSInteger section = layoutAttributes.indexPath.section;
            NSInteger numberOfItemsInSection = [cv numberOfItemsInSection:section];
            
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            
            /**
             *  针对当前layoutAttributes的section， 找出第一个和最底部一个普通cell的位置
             */
            UICollectionViewLayoutAttributes *firstCellAttrs = [self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
            __block UICollectionViewLayoutAttributes *bottomCellAttrs;
            if (self.isWaterfallsFlow) {
                [self.attributesSectionArrm[section] enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (CGRectGetMaxY(bottomCellAttrs.frame) < CGRectGetMaxY(obj.frame)) {
                        bottomCellAttrs = obj;
                    }
                }];
            } else {
                NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
                bottomCellAttrs = [self layoutAttributesForItemAtIndexPath:lastCellIndexPath];
            }
            
            /**
             *  获取当前处理footer的高度
             */
            CGFloat footerHeight = CGRectGetHeight(layoutAttributes.bounds);
            //内间距
            UIEdgeInsets sectionInset;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
                sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
            } else {
                sectionInset = self.sectionInset;
            }
            CGPoint origin = layoutAttributes.frame.origin;
            origin.y = MAX(
                           MIN(
                               contentOffset.y + cv.bounds.size.height - footerHeight,
                               CGRectGetMaxY(bottomCellAttrs.frame) + sectionInset.bottom
                               ),
                           CGRectGetMinY(firstCellAttrs.frame) - sectionInset.top
                           );
            layoutAttributes.zIndex = 1024;
            layoutAttributes.frame = (CGRect){
                .origin = origin,
                .size = layoutAttributes.frame.size
            };
        }
    }];
    return layoutAttributesArrm;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return self.sectionHeadersPinToVisibleBounds || self.sectionFootersPinToVisibleBounds;
}

@end

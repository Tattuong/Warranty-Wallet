import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'package:provider/provider.dart';
import 'package:warranty_wallet/providers/shop_provider.dart';
import 'package:warranty_wallet/widgets/coin_purchase_sheet.dart';

class _ThrowingIap extends InAppPurchasePlatform {
  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) async {
    throw StateError('billing down');
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    throw StateError('billing down');
  }
}

class _GatedIap extends InAppPurchasePlatform {
  final Completer<bool> gate = Completer<bool>();

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) {
    return gate.future;
  }
}

ProductDetails _pack() {
  return ProductDetails(
    id: 'ww_pack_1',
    title: 'Pack',
    description: 'Coins',
    price: r'$1',
    rawPrice: 1,
    currencyCode: 'USD',
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('coin sheet stays partial and empty billing stays short',
      (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final shop = ShopProvider();
    addTearDown(shop.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: shop,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => CoinPurchaseSheet.show(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Billing not available on this device'), findsOneWidget);
    expect(
        find.text(
            'Earn coins by daily login, adding devices & saving invoices'),
        findsOneWidget);
    expect(find.byType(ListView), findsNothing);

    final emptyHeight = tester.getSize(find.byType(BottomSheet)).height;
    expect(emptyHeight, lessThan(400));

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    shop.billing.isAvailable = true;
    shop.billing.coinProducts = List<ProductDetails>.generate(10, (i) {
      return ProductDetails(
        id: 'ww_pack_${i + 1}',
        title: 'Pack',
        description: 'Coins',
        price: '\$${i + 1}',
        rawPrice: (i + 1).toDouble(),
        currencyCode: 'USD',
      );
    });

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Coin Pack 1'), findsOneWidget);
    expect(
        find.text(
            'Earn coins by daily login, adding devices & saving invoices'),
        findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Coin Pack 10'),
      120,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Coin Pack 10'), findsOneWidget);
    expect(
        find.text(
            'Earn coins by daily login, adding devices & saving invoices'),
        findsOneWidget);

    final packedHeight = tester.getSize(find.byType(BottomSheet)).height;
    expect(packedHeight, lessThan(800 * 0.85));
  });

  testWidgets('a billing exception clears the purchasing flag', (tester) async {
    final previous = InAppPurchasePlatform.instance;
    InAppPurchasePlatform.instance = _ThrowingIap();
    addTearDown(() => InAppPurchasePlatform.instance = previous);

    final shop = ShopProvider();
    addTearDown(shop.dispose);
    shop.billing.isAvailable = true;
    shop.billing.removeAdsProduct = ProductDetails(
      id: 'ww_remove_ads',
      title: 'Remove ads',
      description: 'Ads',
      price: r'$2',
      rawPrice: 2,
      currencyCode: 'USD',
    );

    final coinsOk = await shop.buyCoinPack(_pack());
    expect(coinsOk, isFalse);
    expect(shop.isPurchasing, isFalse);
    expect(shop.lastMessage, 'purchaseFailed');

    final adsOk = await shop.buyRemoveAdsViaBilling();
    expect(adsOk, isFalse);
    expect(shop.isPurchasing, isFalse);
    expect(shop.lastMessage, 'purchaseFailed');
  });

  testWidgets(
      'dismissing Play clears the spinner without covering a resumed purchase',
      (tester) async {
    final previous = InAppPurchasePlatform.instance;
    final iap = _GatedIap();
    InAppPurchasePlatform.instance = iap;
    addTearDown(() => InAppPurchasePlatform.instance = previous);

    final shop = ShopProvider();
    addTearDown(shop.dispose);
    shop.billing.isAvailable = true;

    final pending = shop.buyCoinPack(_pack());
    await tester.pump();
    expect(shop.isPurchasing, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    shop.releasePurchaseUi();
    expect(shop.isPurchasing, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump(const Duration(seconds: 13));
    expect(shop.isPurchasing, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 500));
    expect(shop.isPurchasing, isTrue);
    await tester.pump(const Duration(milliseconds: 200));
    expect(shop.isPurchasing, isFalse);

    iap.gate.complete(true);
    expect(await pending, isTrue);
    expect(shop.lastMessage, isNull);
  });
}
